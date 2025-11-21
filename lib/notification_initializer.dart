import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel(
      'datadate_channel',
      'DataDate Notifications',
      description: 'This channel is used for DataDate push notifications.',
      importance: Importance.high,
      enableLights: true,
    );

/// Initializes push + local notifications.
/// Returns true if a new FCM token was generated and stored.
Future<bool> initializeNotifications(ApiClient apiClient) async {
  final messaging = FirebaseMessaging.instance;
  final prefs = await SharedPreferences.getInstance();

  // Request notification permission (mainly for iOS)
  await messaging.requestPermission();

  final storedToken = prefs.getString('fcmToken');

  // Get current token
  try {
    final token = await messaging.getToken();
    if (token != null) {
      // Only update if token changed
      if (storedToken != token) {
        await prefs.setString('fcmToken', token);
        if (kDebugMode) {
          print('✅ FCM Token (new/updated): $token');
        }

        // Send to backend
        await _updateFcmTokenOnBackend(apiClient, token);
        return true;
      } else {
        if (kDebugMode) {
          print('ℹ️ FCM Token (unchanged): $token');
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error getting FCM token: $e');
    }
  }

  // ✅ Handle future token refreshes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final prefs = await SharedPreferences.getInstance();
    final oldToken = prefs.getString('fcmToken');

    // Only update if token actually changed
    if (oldToken != newToken) {
      await prefs.setString('fcmToken', newToken);
      if (kDebugMode) {
        print('🔄 FCM Token refreshed: $newToken');
      }

      // Send to backend
      await _updateFcmTokenOnBackend(apiClient, newToken);
    }
  });

  // 🔔 Local Notification Setup
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (kDebugMode) {
        print('Notification tapped: ${response.payload}');
      }
      // TODO: Handle navigation based on payload if needed
    },
  );

  // ✅ Create custom notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(notificationChannel);

  // 🟢 Listen for foreground push messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received: ${message.data}');
    }

    if (message.notification != null) {
      _showNotification(message);
    }
  });

  return false;
}

/// Update FCM token on backend (POST /auth/fcm-token/)
Future<void> _updateFcmTokenOnBackend(ApiClient apiClient, String token) async {
  try {
    await apiClient.post('/auth/fcm-token/', data: {'fcm_token': token});
    if (kDebugMode) {
      print('✅ FCM token updated on backend');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error updating FCM token on backend: $e');
    }
  }
}

/// Show a local notification when a push arrives in foreground
void _showNotification(RemoteMessage message) {
  const androidDetails = AndroidNotificationDetails(
    'datadate_channel',
    'DataDate Notifications',
    channelDescription: 'This channel is used for DataDate push notifications.',
    importance: Importance.high,
    priority: Priority.high,
    enableLights: true,
  );

  const details = NotificationDetails(android: androidDetails);

  flutterLocalNotificationsPlugin.show(
    message.messageId.hashCode,
    message.notification?.title,
    message.notification?.body,
    details,
    payload: message.data['type'],
  );
}
