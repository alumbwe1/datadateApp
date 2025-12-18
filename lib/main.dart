import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/services/performance_service.dart';
import 'core/services/state_persistence_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/custom_logs.dart';
import 'core/widgets/error_boundary.dart';
import 'device_updator.dart';
import 'notification_initializer.dart';

/// Background message handler for Firebase Cloud Messaging
/// This runs in a separate isolate and must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    CustomLogs.info('📬 Background message received: ${message.messageId}');
    CustomLogs.info('Title: ${message.notification?.title}');
    CustomLogs.info('Body: ${message.notification?.body}');
    CustomLogs.info('Data: ${message.data}');
  }
}

void main() async {
  // Global error handling setup
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    CustomLogs.error(
      'Flutter Error: ${details.exception}',
      tag: 'GLOBAL_ERROR',
      error: details.exception,
      stackTrace: details.stack,
    );

    // Send to Crashlytics in production
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    CustomLogs.error(
      'Platform Error: $error',
      tag: 'PLATFORM_ERROR',
      error: error,
      stackTrace: stack,
    );

    if (kReleaseMode) {
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();
  final secureStorage = const FlutterSecureStorage();
  final String? token = await secureStorage.read(
    key: AppConstants.keyAuthToken,
  );
  if (token != null && token.isNotEmpty) {
    CustomLogs.info('Auth token loaded from secure storage', tag: 'MAIN');
    CustomLogs.debug('Auth Token: $token', tag: 'MAIN');
  } else {
    CustomLogs.info('No auth token found in secure storage', tag: 'MAIN');
  }
  // Configure logging system
  _configureLogging();

  // Initialize Firebase and services
  try {
    await Firebase.initializeApp();
    CustomLogs.success('Firebase initialized', tag: 'MAIN');

    // Initialize all services
    await Future.wait([
      PerformanceService.initialize(),
      AnalyticsService.initialize(),
      StatePersistenceService.initialize(),
    ]);

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    CustomLogs.info('Background message handler registered', tag: 'MAIN');

    // Start app performance trace
    await PerformanceService.startTrace(PerformanceService.appStartTrace);
  } catch (e) {
    CustomLogs.error(
      'Firebase/Services initialization failed: $e',
      tag: 'MAIN',
    );
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

  // Track app start
  await AnalyticsService.trackSessionStart();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ErrorBoundary(child: MyApp()),
    ),
  );

  // Stop app start trace
  await PerformanceService.stopTrace(PerformanceService.appStartTrace);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
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
      maxStackTraceLines: 15,

      // Maximum log length before truncation
      maxLogLength: 3000,

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
                FirebaseCrashlytics.instance.recordError(
                  entry.error,
                  entry.stackTrace,
                  reason: entry.message,
                );
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

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
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
