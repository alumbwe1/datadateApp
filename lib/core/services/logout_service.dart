import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/chat/data/services/chat_local_storage_service.dart';
import '../../features/interactions/data/services/matches_local_storage_service.dart';
import '../constants/app_constants.dart';
import '../utils/custom_logs.dart';

class LogoutService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Comprehensive logout that clears all user data
  static Future<void> performLogout() async {
    try {
      CustomLogs.info('🚪 Starting comprehensive logout...');

      // 1. Clear secure storage (tokens, sensitive data)
      await _clearSecureStorage();

      // 2. Clear shared preferences (cached data)
      await _clearSharedPreferences();

      // 3. Clear specific service caches
      await _clearServiceCaches();

      CustomLogs.success('✅ Logout completed successfully');
    } catch (e) {
      CustomLogs.error('❌ Error during logout: $e');
      // Even if there's an error, we should still try to clear what we can
      rethrow;
    }
  }

  /// Clear all secure storage data
  static Future<void> _clearSecureStorage() async {
    try {
      CustomLogs.info('🔐 Clearing secure storage...');

      // Clear specific keys
      await _secureStorage.delete(key: AppConstants.keyAuthToken);
      await _secureStorage.delete(key: AppConstants.keyRefreshToken);
      await _secureStorage.delete(key: AppConstants.keyUserId);

      // Clear all secure storage (more thorough)
      await _secureStorage.deleteAll();

      CustomLogs.info('✅ Secure storage cleared');
    } catch (e) {
      CustomLogs.error('❌ Error clearing secure storage: $e');
    }
  }

  /// Clear all shared preferences data
  static Future<void> _clearSharedPreferences() async {
    try {
      CustomLogs.info('💾 Clearing shared preferences...');

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      CustomLogs.info('✅ Shared preferences cleared');
    } catch (e) {
      CustomLogs.error('❌ Error clearing shared preferences: $e');
    }
  }

  /// Clear specific service caches
  static Future<void> _clearServiceCaches() async {
    try {
      CustomLogs.info('🗂️ Clearing service caches...');

      // Clear chat cache
      await ChatLocalStorageService.clearCache();
      CustomLogs.info('✅ Chat cache cleared');

      // Clear matches cache
      await MatchesLocalStorageService.clearCache();
      CustomLogs.info('✅ Matches cache cleared');

      // Add other service cache clearing here as needed
    } catch (e) {
      CustomLogs.error('❌ Error clearing service caches: $e');
    }
  }

  /// Quick logout (minimal clearing for emergency situations)
  static Future<void> performQuickLogout() async {
    try {
      CustomLogs.info('⚡ Starting quick logout...');

      // Just clear tokens and essential data
      await _secureStorage.delete(key: AppConstants.keyAuthToken);
      await _secureStorage.delete(key: AppConstants.keyRefreshToken);
      await _secureStorage.delete(key: AppConstants.keyUserId);

      CustomLogs.success('✅ Quick logout completed');
    } catch (e) {
      CustomLogs.error('❌ Error during quick logout: $e');
    }
  }

  /// Check if user data exists (for debugging)
  static Future<bool> hasUserData() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
      final prefs = await SharedPreferences.getInstance();
      final hasPrefsData = prefs.getKeys().isNotEmpty;

      return token != null || hasPrefsData;
    } catch (e) {
      CustomLogs.error('❌ Error checking user data: $e');
      return false;
    }
  }

  /// Get data summary (for debugging)
  static Future<Map<String, dynamic>> getDataSummary() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.keyAuthToken);
      final prefs = await SharedPreferences.getInstance();
      final prefsKeys = prefs.getKeys().toList();

      return {
        'hasToken': token != null,
        'prefsKeysCount': prefsKeys.length,
        'prefsKeys': prefsKeys.take(10).toList(), // First 10 keys for debugging
      };
    } catch (e) {
      CustomLogs.error('❌ Error getting data summary: $e');
      return {'error': e.toString()};
    }
  }
}
