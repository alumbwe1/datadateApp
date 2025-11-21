import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';

/// Handles device info updates (FCM token only)
class DeviceInfoUpdater {
  /// Update FCM token on backend if it has changed
  static Future<void> updateFcmTokenIfChanged(ApiClient apiClient) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final fcmToken = prefs.getString('fcmToken');
      if (fcmToken == null) {
        if (kDebugMode) {
          print('ℹ️ No FCM token found, skipping update');
        }
        return;
      }

      final lastSentToken = prefs.getString('lastSentFcmToken');

      // Only update if token has changed
      if (lastSentToken == fcmToken) {
        if (kDebugMode) {
          print('ℹ️ FCM token unchanged, skipping backend update');
        }
        return;
      }

      // Send to backend
      await apiClient.post('/auth/fcm-token/', data: {'fcm_token': fcmToken});

      // Save the token we just sent
      await prefs.setString('lastSentFcmToken', fcmToken);

      if (kDebugMode) {
        print('✅ FCM token updated on backend');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating FCM token: $e');
      }
    }
  }
}
