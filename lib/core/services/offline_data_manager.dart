import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chat/data/services/chat_local_storage_service.dart';
import '../../features/interactions/data/services/matches_local_storage_service.dart';
import '../utils/custom_logs.dart';

class OfflineDataManager {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Preload all cached data when app starts offline
  static Future<void> preloadCachedData(WidgetRef ref) async {
    final hasInternet = await hasInternetConnection();

    if (!hasInternet) {
      CustomLogs.info('📱 Device is offline, loading cached data...');

      // Load cached chat rooms
      final cachedRooms = await ChatLocalStorageService.getCachedChatRooms();
      if (cachedRooms.isNotEmpty) {
        CustomLogs.info('📱 Preloaded ${cachedRooms.length} cached chat rooms');
      }

      // Load cached matches
      final cachedMatches = await MatchesLocalStorageService.getCachedMatches();
      if (cachedMatches.isNotEmpty) {
        CustomLogs.info('📱 Preloaded ${cachedMatches.length} cached matches');
      }
    }
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    await Future.wait([
      ChatLocalStorageService.clearCache(),
      MatchesLocalStorageService.clearCache(),
    ]);
    CustomLogs.info('🗑️ All cached data cleared');
  }

  /// Get cache status information
  static Future<Map<String, dynamic>> getCacheStatus() async {
    final chatRooms = await ChatLocalStorageService.getCachedChatRooms();
    final matches = await MatchesLocalStorageService.getCachedMatches();
    final chatLastUpdate = await ChatLocalStorageService.getLastUpdateTime();
    final matchesLastUpdate =
        await MatchesLocalStorageService.getLastUpdateTime();

    return {
      'chatRoomsCount': chatRooms.length,
      'matchesCount': matches.length,
      'chatLastUpdate': chatLastUpdate?.toIso8601String(),
      'matchesLastUpdate': matchesLastUpdate?.toIso8601String(),
      'hasInternet': await hasInternetConnection(),
    };
  }
}

// Provider for offline status
final offlineStatusProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((result) {
    return result.contains(ConnectivityResult.none);
  });
});

// Provider for cache status
final cacheStatusProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return OfflineDataManager.getCacheStatus();
});
