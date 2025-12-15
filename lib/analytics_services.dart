import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(String name,
      {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint("Analytics error on $name: $e");
    }
  }

  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }

  static Future<void> setUserProperty(String key, String value) async {
    try {
      await _analytics.setUserProperty(name: key, value: value);
    } catch (e) {
      debugPrint("Failed to set user property: $e");
    }
  }

  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint("Failed to log screen view: $e");
    }
  }

  static RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
}
