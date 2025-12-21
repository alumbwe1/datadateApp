import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../utils/custom_logs.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  static FirebaseAnalyticsObserver get observer => _observer;

  /// Initialize analytics
  static Future<void> initialize() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);

      CustomLogs.success('Analytics service initialized', tag: 'ANALYTICS');
    } catch (e) {
      CustomLogs.error(
        'Failed to initialize analytics: $e',
        tag: 'ANALYTICS',
        error: e,
      );
    }
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userId,
    int? age,
    String? gender,
    String? university,
    String? relationshipGoal,
  }) async {
    try {
      if (userId != null) {
        await _analytics.setUserId(id: userId);
      }

      if (age != null) {
        await _analytics.setUserProperty(
          name: 'age_group',
          value: _getAgeGroup(age),
        );
      }

      if (gender != null) {
        await _analytics.setUserProperty(name: 'gender', value: gender);
      }

      if (university != null) {
        await _analytics.setUserProperty(name: 'university', value: university);
      }

      if (relationshipGoal != null) {
        await _analytics.setUserProperty(
          name: 'relationship_goal',
          value: relationshipGoal,
        );
      }

      CustomLogs.debug('User properties set', tag: 'ANALYTICS');
    } catch (e) {
      CustomLogs.error(
        'Failed to set user properties: $e',
        tag: 'ANALYTICS',
        error: e,
      );
    }
  }

  /// Track screen views
  static Future<void> trackScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);

      if (kDebugMode) {
        CustomLogs.debug('Screen view tracked: $screenName', tag: 'ANALYTICS');
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to track screen view: $e',
        tag: 'ANALYTICS',
        error: e,
      );
    }
  }

  /// User engagement events
  static Future<void> trackUserRegistration({
    required String method,
    String? university,
  }) async {
    await _logEvent('sign_up', {
      'method': method,
      if (university != null) 'university': university,
    });
  }

  static Future<void> trackUserLogin({required String method}) async {
    await _logEvent('login', {'method': method});
  }

  static Future<void> trackProfileCompletion({
    required double completionPercentage,
  }) async {
    await _logEvent('profile_completion', {
      'completion_percentage': completionPercentage,
    });
  }

  /// Dating-specific events
  static Future<void> trackSwipeAction({
    required String action, // 'like', 'pass', 'super_like'
    required String profileId,
  }) async {
    await _logEvent('swipe_action', {
      'action': action,
      'profile_id': profileId,
    });
  }

  static Future<void> trackMatch({
    required String matchId,
    required String profileId,
  }) async {
    await _logEvent('match_found', {
      'match_id': matchId,
      'profile_id': profileId,
    });
  }

  static Future<void> trackMessageSent({
    required String chatId,
    required String messageType, // 'text', 'image', 'voice'
  }) async {
    await _logEvent('message_sent', {
      'chat_id': chatId,
      'message_type': messageType,
    });
  }

  static Future<void> trackVideoCall({
    required String callId,
    required int duration, // in seconds
    required String endReason, // 'completed', 'declined', 'failed'
  }) async {
    await _logEvent('video_call', {
      'call_id': callId,
      'duration': duration,
      'end_reason': endReason,
    });
  }

  /// Feature usage events
  static Future<void> trackFeatureUsage({
    required String featureName,
    Map<String, dynamic>? parameters,
  }) async {
    await _logEvent('feature_used', {
      'feature_name': featureName,
      ...?parameters,
    });
  }

  static Future<void> trackFilterUsage({
    required Map<String, dynamic> filters,
  }) async {
    await _logEvent('filters_applied', filters);
  }

  static Future<void> trackBoostPurchase({
    required String boostType,
    required double price,
  }) async {
    await _logEvent('boost_purchase', {
      'boost_type': boostType,
      'price': price,
      'currency': 'USD',
    });
  }

  /// User behavior events
  static Future<void> trackAppSessionStart() async {
    await _logEvent('app_session_start', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> trackAppSessionEnd({
    required int duration, // in seconds
  }) async {
    await _logEvent('app_session_end', {'duration': duration});
  }

  static Future<void> trackAppCrash({
    required String error,
    String? stackTrace,
  }) async {
    await _logEvent('app_crash', {
      'error': error,
      if (stackTrace != null) 'stack_trace': stackTrace,
    });
  }

  /// Conversion events
  static Future<void> trackPremiumUpgrade({
    required String planType,
    required double price,
  }) async {
    await _logEvent('premium_upgrade', {
      'plan_type': planType,
      'price': price,
      'currency': 'USD',
    });
  }

  static Future<void> trackProfileView({
    required String profileId,
    required String source, // 'encounters', 'search', 'likes'
  }) async {
    await _logEvent('profile_view', {
      'profile_id': profileId,
      'source': source,
    });
  }

  /// A/B Testing events
  static Future<void> trackExperimentParticipation({
    required String experimentName,
    required String variant,
  }) async {
    await _logEvent('experiment_participation', {
      'experiment_name': experimentName,
      'variant': variant,
    });
  }

  /// Performance events
  static Future<void> trackPerformanceMetric({
    required String metricName,
    required double value,
    String? unit,
  }) async {
    await _logEvent('performance_metric', {
      'metric_name': metricName,
      'value': value,
      if (unit != null) 'unit': unit,
    });
  }

  /// Private helper methods
  static Future<void> _logEvent(
    String eventName,
    Map<String, dynamic> parameters,
  ) async {
    try {
      // Sanitize parameters to ensure they're analytics-safe
      final sanitizedParams = _sanitizeParameters(parameters);

      await _analytics.logEvent(name: eventName, parameters: sanitizedParams);

      if (kDebugMode) {
        CustomLogs.debug(
          'Event tracked: $eventName with params: $sanitizedParams',
          tag: 'ANALYTICS',
        );
      }
    } catch (e) {
      CustomLogs.error(
        'Failed to log event $eventName: $e',
        tag: 'ANALYTICS',
        error: e,
      );
    }
  }

  static Map<String, Object> _sanitizeParameters(Map<String, dynamic> params) {
    final sanitized = <String, Object>{};

    for (final entry in params.entries) {
      final key = entry.key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final value = entry.value;

      // Ensure value types are supported by Firebase Analytics
      if (value is String || value is num || value is bool) {
        sanitized[key] = value;
      } else {
        sanitized[key] = value.toString();
      }
    }

    return sanitized;
  }

  static String _getAgeGroup(int age) {
    if (age < 20) return '18-19';
    if (age < 25) return '20-24';
    if (age < 30) return '25-29';
    if (age < 35) return '30-34';
    return '35+';
  }
}
