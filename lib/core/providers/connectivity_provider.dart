import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

// Connectivity service provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// Connection info stream provider
final connectionInfoProvider = StreamProvider<ConnectionInfo>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectionStream;
});

// Current connection provider (synchronous)
final currentConnectionProvider = Provider<ConnectionInfo>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.currentConnection;
});

// Helper providers for specific connection states
final isConnectedProvider = Provider<bool>((ref) {
  final connection = ref.watch(currentConnectionProvider);
  return connection.isConnected;
});

final isSlowConnectionProvider = Provider<bool>((ref) {
  final connection = ref.watch(currentConnectionProvider);
  return connection.isSlow;
});

final connectionStatusTextProvider = Provider<String>((ref) {
  final connection = ref.watch(currentConnectionProvider);

  switch (connection.status) {
    case ConnectionStatus.none:
      return 'No Internet';
    case ConnectionStatus.slow:
      return 'Slow Connection';
    case ConnectionStatus.good:
      return 'Good Connection';
    case ConnectionStatus.excellent:
      return 'Excellent Connection';
  }
});

final connectionTypeTextProvider = Provider<String>((ref) {
  final connection = ref.watch(currentConnectionProvider);

  switch (connection.type) {
    case ConnectionType.none:
      return 'No Connection';
    case ConnectionType.mobile:
      return 'Mobile Data';
    case ConnectionType.wifi:
      return 'Wi-Fi';
    case ConnectionType.ethernet:
      return 'Ethernet';
    case ConnectionType.vpn:
      return 'VPN';
    case ConnectionType.bluetooth:
      return 'Bluetooth';
    case ConnectionType.other:
      return 'Other';
  }
});
