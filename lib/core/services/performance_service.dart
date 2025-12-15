import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import '../utils/custom_logs.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  static final Map<String, Trace> _activeTraces = {};

  /// Initialize performance monitoring
  static Future<void> initialize() async {
    try {
      // Enable performance monitoring
      await _performance.setPerformanceCollectionEnabled(true);

      CustomLogs.success(
        'Performance monitoring initialized',
        tag: 'PERFORMANCE',
      );
    } catch (e) {
      CustomLogs.error(
        'Failed to initialize performance monitoring: $e',
        tag: 'PERFORMANCE',
        error: e,
      );
    }
  }

  /// Start a custom trace
  static Future<void> startTrace(String traceName) async {
    try {
      if (_activeTraces.containsKey(traceName)) {
        CustomLogs.warning(
          'Trace $traceName already active',
          tag: 'PERFORMANCE',
        );
        return;
      }

      final trace = _performance.newTrace(traceName);
      await trace.start();
      _activeTraces[traceName] = trace;

      if (kDebugMode) {
        CustomLogs.debug('Started trace: $traceName', tag: 'PERFORMANCE');
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to start trace $traceName: $e',
        tag: 'PERFORMANCE',
        error: e,
      );
    }
  }

  /// Stop a custom trace
  static Future<void> stopTrace(String traceName) async {
    try {
      final trace = _activeTraces.remove(traceName);
      if (trace == null) {
        CustomLogs.warning('Trace $traceName not found', tag: 'PERFORMANCE');
        return;
      }

      await trace.stop();

      if (kDebugMode) {
        CustomLogs.debug('Stopped trace: $traceName', tag: 'PERFORMANCE');
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to stop trace $traceName: $e',
        tag: 'PERFORMANCE',
        error: e,
      );
    }
  }

  /// Add custom attribute to trace
  static void setTraceAttribute(String traceName, String key, String value) {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        CustomLogs.warning(
          'Trace $traceName not found for attribute $key',
          tag: 'PERFORMANCE',
        );
        return;
      }

      trace.putAttribute(key, value);

      if (kDebugMode) {
        CustomLogs.debug(
          'Set attribute $key=$value for trace $traceName',
          tag: 'PERFORMANCE',
        );
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to set attribute for trace $traceName: $e',
        tag: 'PERFORMANCE',
        error: e,
      );
    }
  }

  /// Increment metric for trace
  static void incrementMetric(String traceName, String metricName, int value) {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        CustomLogs.warning(
          'Trace $traceName not found for metric $metricName',
          tag: 'PERFORMANCE',
        );
        return;
      }

      trace.incrementMetric(metricName, value);

      if (kDebugMode) {
        CustomLogs.debug(
          'Incremented metric $metricName by $value for trace $traceName',
          tag: 'PERFORMANCE',
        );
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to increment metric for trace $traceName: $e',
        tag: 'PERFORMANCE',
        error: e,
      );
    }
  }

  /// Monitor HTTP requests automatically
  static HttpMetric newHttpMetric(String url, HttpMethod httpMethod) {
    return _performance.newHttpMetric(url, httpMethod);
  }

  /// Common trace names for the app
  static const String appStartTrace = 'app_start';
  static const String loginTrace = 'user_login';
  static const String profileLoadTrace = 'profile_load';
  static const String encountersLoadTrace = 'encounters_load';
  static const String chatLoadTrace = 'chat_load';
  static const String imageUploadTrace = 'image_upload';
  static const String swipeActionTrace = 'swipe_action';
  static const String matchFoundTrace = 'match_found';
}

/// Extension to easily wrap async operations with performance tracing
extension PerformanceTracing<T> on Future<T> {
  Future<T> withTrace(String traceName) async {
    await PerformanceService.startTrace(traceName);
    try {
      final result = await this;
      await PerformanceService.stopTrace(traceName);
      return result;
    } catch (e) {
      await PerformanceService.stopTrace(traceName);
      rethrow;
    }
  }
}
