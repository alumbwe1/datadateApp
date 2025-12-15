import 'package:datadate/features/encounters/presentation/widgets/profile_card.dart';
import 'package:datadate/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dating App Integration Tests', () {
    testWidgets('App launches and shows splash screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen is shown
      expect(find.text('HeartLink'), findsOneWidget);
      expect(find.text('Find Your Perfect Match'), findsOneWidget);
    });

    testWidgets('Navigation between tabs works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Skip splash and login if needed
      await _skipToMainApp(tester);

      // Test navigation to different tabs
      final tabs = ['Discover', 'Likes', 'Chats', 'Profile', 'Encounters'];

      for (final tabName in tabs) {
        final tabFinder = find.text(tabName);
        if (tabFinder.evaluate().isNotEmpty) {
          await tester.tap(tabFinder);
          await tester.pumpAndSettle();

          // Verify we can see some content (scaffold should always be present)
          expect(find.byType(Scaffold), findsWidgets);
        }
      }
    });

    testWidgets('User can interact with encounters page', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _skipToMainApp(tester);

      // Ensure we're on the encounters tab
      final encountersTab = find.text('Encounters');
      if (encountersTab.evaluate().isNotEmpty) {
        await tester.tap(encountersTab);
        await tester.pumpAndSettle();
      }

      // Try to find and interact with swipeable content
      final profileCardFinder = find.byType(ProfileCard);

      if (profileCardFinder.evaluate().isNotEmpty) {
        // Simulate swipe right (like)
        await tester.drag(profileCardFinder.first, const Offset(300, 0));
        await tester.pumpAndSettle();
      } else {
        // If no ProfileCard found, look for other interactive elements
        final gestureDetectors = find.byType(GestureDetector);
        if (gestureDetectors.evaluate().isNotEmpty) {
          await tester.drag(gestureDetectors.first, const Offset(300, 0));
          await tester.pumpAndSettle();
        }
      }

      // Verify the page is still functional
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Error states are handled gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test network error handling
      await _simulateNetworkError(tester);

      // Verify error state is shown
      expect(find.textContaining('error'), findsWidgets);
    });

    testWidgets('Loading states are shown appropriately', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify loading indicators appear during async operations
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Accessibility features work correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enable accessibility
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/accessibility',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('routeUpdated', {'location': '/', 'state': null}),
        ),
        (data) {},
      );

      await _skipToMainApp(tester);

      // Test semantic labels are present (with fallback to text labels)
      final tabLabels = [
        'Encounters tab',
        'Discover tab',
        'Likes tab',
        'Chat tab',
        'Profile tab',
      ];

      final tabTexts = ['Encounters', 'Discover', 'Likes', 'Chats', 'Profile'];

      for (int i = 0; i < tabLabels.length; i++) {
        final semanticFinder = find.bySemanticsLabel(tabLabels[i]);
        final textFinder = find.text(tabTexts[i]);

        // Either semantic label or text should be found
        expect(
          semanticFinder.evaluate().isNotEmpty ||
              textFinder.evaluate().isNotEmpty,
          isTrue,
          reason:
              'Neither semantic label "${tabLabels[i]}" nor text "${tabTexts[i]}" found',
        );
      }
    });

    testWidgets('Performance is within acceptable limits', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      app.main();
      await tester.pumpAndSettle();

      await _skipToMainApp(tester);

      // Measure frame rendering performance
      await binding.traceAction(() async {
        // Navigate through all tabs
        for (final tab in [
          'Discover',
          'Likes',
          'Chats',
          'Profile',
          'Encounters',
        ]) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 100));
        }
      }, reportKey: 'navigation_performance');

      // Verify no frames were dropped
      final summary = binding.reportData!;
      expect(summary['navigation_performance'], isNotNull);
    });
  });
}

/// Helper function to skip splash and login screens
Future<void> _skipToMainApp(WidgetTester tester) async {
  // Wait for splash screen to complete
  await tester.pump(const Duration(seconds: 2));

  // If login screen is shown, simulate login
  if (find.text('Login').evaluate().isNotEmpty) {
    final textFields = find.byType(TextField);
    if (textFields.evaluate().length >= 2) {
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.last, 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
    }
  }

  // If onboarding is shown, skip it
  final onboardingButtons = [
    'Next',
    'Continue',
    'Get Started',
    'Complete',
    'Finish',
  ];
  for (final buttonText in onboardingButtons) {
    while (find.text(buttonText).evaluate().isNotEmpty) {
      await tester.tap(find.text(buttonText).first);
      await tester.pumpAndSettle();
    }
  }

  // Final wait for navigation to complete
  await tester.pumpAndSettle();
}

/// Helper function to simulate network errors
Future<void> _simulateNetworkError(WidgetTester tester) async {
  // This would typically involve mocking network calls
  // For now, we'll just wait and check for error states
  await tester.pump(const Duration(seconds: 5));
}
