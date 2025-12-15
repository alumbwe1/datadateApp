import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class IntegrationTestHelpers {
  /// Safely tap a widget if it exists
  static Future<bool> safeTap(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      return true;
    }
    return false;
  }

  /// Wait for a widget to appear with timeout
  static Future<bool> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Skip onboarding flow if present
  static Future<void> skipOnboarding(WidgetTester tester) async {
    // Common onboarding button texts
    final onboardingButtons = [
      'Next',
      'Continue',
      'Get Started',
      'Skip',
      'Complete',
      'Finish',
    ];

    for (final buttonText in onboardingButtons) {
      while (find.text(buttonText).evaluate().isNotEmpty) {
        await safeTap(tester, find.text(buttonText));
        await tester.pump(const Duration(milliseconds: 500));
      }
    }
  }

  /// Navigate to a specific tab
  static Future<bool> navigateToTab(WidgetTester tester, String tabName) async {
    final tabFinder = find.text(tabName);
    return await safeTap(tester, tabFinder);
  }

  /// Check if app is in main navigation state
  static bool isInMainApp(WidgetTester tester) {
    final mainTabs = ['Encounters', 'Discover', 'Likes', 'Chats', 'Profile'];
    return mainTabs.any((tab) => find.text(tab).evaluate().isNotEmpty);
  }

  /// Simulate login if login screen is present
  static Future<bool> simulateLogin(WidgetTester tester) async {
    final loginButton = find.text('Login');
    final emailField = find.byType(TextField);

    if (loginButton.evaluate().isNotEmpty &&
        emailField.evaluate().length >= 2) {
      await tester.enterText(emailField.first, 'test@example.com');
      await tester.enterText(emailField.last, 'password123');
      return await safeTap(tester, loginButton);
    }
    return false;
  }

  /// Get to main app from any state
  static Future<void> getToMainApp(WidgetTester tester) async {
    // Wait for splash screen to complete
    await tester.pump(const Duration(seconds: 2));

    // Try to login if needed
    await simulateLogin(tester);

    // Skip onboarding if present
    await skipOnboarding(tester);

    // Wait a bit more for navigation to complete
    await tester.pumpAndSettle();

    // Verify we're in the main app
    if (!isInMainApp(tester)) {
      // Try one more time with longer wait
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }
  }

  /// Perform swipe gesture safely
  static Future<bool> performSwipe(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.drag(finder.first, offset);
      await tester.pumpAndSettle();
      return true;
    }
    return false;
  }

  /// Check if widget exists with timeout
  static Future<bool> expectWidgetEventually(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return await waitForWidget(tester, finder, timeout: timeout);
  }
}
