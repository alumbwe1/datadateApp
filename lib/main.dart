import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/custom_logs.dart';
import 'device_updator.dart';
import 'notification_initializer.dart';

/// Background message handler for Firebase Cloud Messaging
/// This runs in a separate isolate and must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('📬 Background message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }

  // Handle the message (e.g., show notification, update local data)
  // Note: You can't update UI here, only handle data
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging system
  _configureLogging();

  // Initialize Firebase
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    CustomLogs.success('Firebase initialized', tag: 'MAIN');

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    CustomLogs.info('Background message handler registered', tag: 'MAIN');
  } catch (e) {
    CustomLogs.error('Firebase initialization failed: $e', tag: 'MAIN');
  }
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create API client for initialization
  final apiClient = ApiClient();

  // Initialize notifications (FCM)
  try {
    final tokenUpdated = await initializeNotifications(apiClient);
    if (tokenUpdated) {
      CustomLogs.success(
        'FCM token initialized and sent to backend',
        tag: 'MAIN',
      );
    } else {
      CustomLogs.info('FCM token unchanged', tag: 'MAIN');
    }
  } catch (e) {
    CustomLogs.error('Notification initialization failed: $e', tag: 'MAIN');
  }

  // Update device info (FCM token) if changed
  try {
    await DeviceInfoUpdater.updateFcmTokenIfChanged(apiClient);
  } catch (e) {
    CustomLogs.error('Device info update failed: $e', tag: 'MAIN');
  }

  // Log app startup
  CustomLogs.success(
    'App initialized successfully',
    tag: 'MAIN',
    metadata: {
      'mode': kDebugMode
          ? 'debug'
          : kReleaseMode
          ? 'release'
          : 'profile',
      'platform': defaultTargetPlatform.name,
    },
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

/// Configure logging system based on build mode
void _configureLogging() {
  CustomLogs.configure(
    LogConfig(
      // Enable logging in release mode for critical errors only
      enableInRelease: false,

      // Set minimum log level based on build mode
      minLevel: kDebugMode ? LogLevel.debug : LogLevel.warning,

      // Always sanitize sensitive data for security
      sanitizeSensitiveData: true,

      // Placeholder for redacted data
      redactedPlaceholder: '[REDACTED]',

      // Include stack traces in debug mode only
      includeStackTrace: kDebugMode,

      // Limit stack trace lines to prevent log overflow
      maxStackTraceLines: 10,

      // Maximum log length before truncation
      maxLogLength: 2000,

      // Include metadata for better debugging
      includeMetadata: true,

      // Add custom sensitive patterns if needed
      customSensitivePatterns: [
        // Add any app-specific sensitive patterns here
        // Example: RegExp(r'custom_secret_pattern'),
      ],

      // Optional: Send logs to external service (Firebase, Sentry, etc.)
      onLog: kReleaseMode
          ? (entry) {
              // In production, only log errors to external service
              if (entry.level == LogLevel.error) {
                // TODO: Send to Firebase Crashlytics or Sentry
                // FirebaseCrashlytics.instance.recordError(
                //   entry.error,
                //   entry.stackTrace,
                //   reason: entry.message,
                // );
              }
            }
          : null,
    ),
  );

  CustomLogs.info(
    'Logging system configured',
    tag: 'MAIN',
    metadata: {
      'sanitizeSensitiveData': true,
      'includeStackTrace': kDebugMode,
      'minLevel': kDebugMode ? 'debug' : 'warning',
    },
  );
}

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'DataDate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
