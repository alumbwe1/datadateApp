import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum ConnectionStatus { none, slow, good, excellent }

enum ConnectionType { none, mobile, wifi, ethernet, vpn, bluetooth, other }

class ConnectionInfo {
  final ConnectionStatus status;
  final ConnectionType type;
  final int? speed; // in Mbps
  final int latency; // in milliseconds
  final bool isStable;

  const ConnectionInfo({
    required this.status,
    required this.type,
    this.speed,
    required this.latency,
    required this.isStable,
  });

  bool get isConnected => status != ConnectionStatus.none;
  bool get isSlow => status == ConnectionStatus.slow;
  bool get isGood =>
      status == ConnectionStatus.good || status == ConnectionStatus.excellent;

  @override
  String toString() {
    return 'ConnectionInfo(status: $status, type: $type, speed: ${speed}Mbps, latency: ${latency}ms, stable: $isStable)';
  }
}

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio();

  StreamController<ConnectionInfo>? _connectionController;
  Timer? _speedTestTimer;
  Timer? _stabilityTimer;

  // Add failure tracking to reduce spam
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 3;

  ConnectionInfo _currentConnection = const ConnectionInfo(
    status: ConnectionStatus.none,
    type: ConnectionType.none,
    latency: 0,
    isStable: false,
  );

  // Speed test configuration
  static const Duration _speedTestInterval = Duration(seconds: 30);
  static const Duration _stabilityCheckInterval = Duration(seconds: 5);
  static const int _maxLatencyForGood = 100; // ms
  static const int _maxLatencyForSlow = 500; // ms
  static const List<String> _testUrls = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://httpbin.org/get',
  ];

  Stream<ConnectionInfo> get connectionStream {
    _connectionController ??= StreamController<ConnectionInfo>.broadcast();
    return _connectionController!.stream;
  }

  ConnectionInfo get currentConnection => _currentConnection;

  Future<void> initialize() async {
    debugPrint('🌐 Initializing ConnectivityService');

    // Configure Dio for speed tests with more resilient timeouts
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 3), // Reduced from 5s
      receiveTimeout: const Duration(seconds: 5), // Reduced from 10s
      sendTimeout: const Duration(seconds: 3), // Reduced from 5s
      // Add retry interceptor for failed requests
      validateStatus: (status) => status != null && status < 500,
    );

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // Initial connection check
    await _checkConnection();

    // Start periodic speed tests
    _startPeriodicSpeedTests();

    // Start stability monitoring
    _startStabilityMonitoring();
  }

  void dispose() {
    debugPrint('🌐 Disposing ConnectivityService');
    _speedTestTimer?.cancel();
    _stabilityTimer?.cancel();
    _connectionController?.close();
    _connectionController = null;
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    debugPrint('🌐 Connectivity changed: $results');
    await _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final connectionType = _mapConnectivityResult(connectivityResults);

      if (connectionType == ConnectionType.none) {
        _updateConnection(
          const ConnectionInfo(
            status: ConnectionStatus.none,
            type: ConnectionType.none,
            latency: 0,
            isStable: false,
          ),
        );
        return;
      }

      // Test actual internet connectivity and speed
      final speedTestResult = await _performSpeedTest();
      final connectionStatus = _determineConnectionStatus(speedTestResult);

      _updateConnection(
        ConnectionInfo(
          status: connectionStatus,
          type: connectionType,
          speed: speedTestResult['speed'],
          latency: speedTestResult['latency'] ?? 0,
          isStable: speedTestResult['stable'] ?? false,
        ),
      );
    } catch (e) {
      // Handle connection check failures gracefully
      if (kDebugMode) {
        debugPrint('🌐 Error checking connection: ${e.toString()}');
      }

      _updateConnection(
        const ConnectionInfo(
          status: ConnectionStatus.none,
          type: ConnectionType.none,
          latency: 0,
          isStable: false,
        ),
      );
    }
  }

  ConnectionType _mapConnectivityResult(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectionType.none;
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    } else if (results.contains(ConnectivityResult.vpn)) {
      return ConnectionType.vpn;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return ConnectionType.bluetooth;
    }

    return ConnectionType.other;
  }

  Future<Map<String, dynamic>> _performSpeedTest() async {
    final List<int> latencies = [];
    final List<bool> successes = [];
    final Stopwatch stopwatch = Stopwatch();

    for (final url in _testUrls) {
      try {
        stopwatch.reset();
        stopwatch.start();

        final response = await _dio.get(
          url,
          options: Options(headers: {'Cache-Control': 'no-cache'}),
        );

        stopwatch.stop();

        if (response.statusCode == 200) {
          latencies.add(stopwatch.elapsedMilliseconds);
          successes.add(true);
        } else {
          successes.add(false);
        }
      } catch (e) {
        successes.add(false);
        // Only log speed test failures in debug mode to avoid spam
        if (kDebugMode) {
          debugPrint('🌐 Speed test failed for $url: ${e.toString()}');
        }
      }
    }

    // Calculate average latency
    final avgLatency = latencies.isNotEmpty
        ? latencies.reduce((a, b) => a + b) ~/ latencies.length
        : 1000;

    // Calculate success rate for stability
    final successRate = successes.where((s) => s).length / successes.length;
    final isStable = successRate >= 0.7; // 70% success rate

    // Update failure tracking
    if (successRate < 0.3) {
      // Less than 30% success rate
      _consecutiveFailures++;
    } else {
      _consecutiveFailures = 0; // Reset on successful test
    }

    // Estimate speed based on latency (rough approximation)
    int? estimatedSpeed;
    if (avgLatency < 50) {
      estimatedSpeed = 50; // Excellent
    } else if (avgLatency < 100) {
      estimatedSpeed = 25; // Good
    } else if (avgLatency < 300) {
      estimatedSpeed = 10; // Fair
    } else {
      estimatedSpeed = 2; // Slow
    }

    return {
      'latency': avgLatency,
      'speed': estimatedSpeed,
      'stable': isStable,
      'successRate': successRate,
    };
  }

  ConnectionStatus _determineConnectionStatus(Map<String, dynamic> speedTest) {
    final latency = speedTest['latency'] as int;
    final stable = speedTest['stable'] as bool;

    if (!stable) {
      return ConnectionStatus.slow;
    }

    if (latency <= _maxLatencyForGood) {
      return latency <= 50 ? ConnectionStatus.excellent : ConnectionStatus.good;
    } else if (latency <= _maxLatencyForSlow) {
      return ConnectionStatus.slow;
    } else {
      return ConnectionStatus.slow;
    }
  }

  void _updateConnection(ConnectionInfo newConnection) {
    if (_currentConnection.status != newConnection.status ||
        _currentConnection.type != newConnection.type) {
      debugPrint('🌐 Connection updated: $newConnection');
      _currentConnection = newConnection;
      _connectionController?.add(newConnection);
    }
  }

  void _startPeriodicSpeedTests() {
    _speedTestTimer = Timer.periodic(_speedTestInterval, (timer) {
      if (_currentConnection.isConnected) {
        // Skip speed tests if we've had too many consecutive failures
        if (_consecutiveFailures >= _maxConsecutiveFailures) {
          if (kDebugMode) {
            debugPrint('🌐 Skipping speed test due to consecutive failures');
          }
          return;
        }
        _checkConnection();
      }
    });
  }

  void _startStabilityMonitoring() {
    _stabilityTimer = Timer.periodic(_stabilityCheckInterval, (timer) {
      if (_currentConnection.isConnected) {
        _quickConnectivityCheck();
      }
    });
  }

  Future<void> _quickConnectivityCheck() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.get(
        'https://www.google.com',
        options: Options(
          headers: {'Cache-Control': 'no-cache'},
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      stopwatch.stop();

      if (response.statusCode != 200) {
        _updateConnection(
          _currentConnection.copyWith(
            status: ConnectionStatus.slow,
            isStable: false,
          ),
        );
      }
    } catch (e) {
      // Silently handle connectivity check failures to avoid spam
      // Only update connection status, don't log in production
      if (kDebugMode) {
        debugPrint('🌐 Quick connectivity check failed: ${e.toString()}');
      }

      _updateConnection(
        _currentConnection.copyWith(
          status: ConnectionStatus.slow,
          isStable: false,
        ),
      );
    }
  }

  // Manual refresh method for user-triggered checks
  Future<void> refreshConnection() async {
    debugPrint('🌐 Manual connection refresh requested');
    await _checkConnection();
  }
}

extension ConnectionInfoExtension on ConnectionInfo {
  ConnectionInfo copyWith({
    ConnectionStatus? status,
    ConnectionType? type,
    int? speed,
    int? latency,
    bool? isStable,
  }) {
    return ConnectionInfo(
      status: status ?? this.status,
      type: type ?? this.type,
      speed: speed ?? this.speed,
      latency: latency ?? this.latency,
      isStable: isStable ?? this.isStable,
    );
  }
}
