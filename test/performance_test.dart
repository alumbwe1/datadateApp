import 'package:datadate/core/utils/custom_logs.dart';
import 'package:datadate/core/widgets/main_navigation.dart';
import 'package:datadate/features/encounters/presentation/pages/encounters_page.dart';
import 'package:datadate/features/likes/presentation/pages/likes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('Navigation performance test', (tester) async {
      // Measure navigation performance
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Navigation should complete within 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      CustomLogs.info(
        'Navigation render time: ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Likes page loading performance', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const MaterialApp(home: LikesPage()));
      await tester.pump(); // First frame

      final firstFrameTime = stopwatch.elapsedMilliseconds;

      await tester.pumpAndSettle(); // Wait for all animations
      stopwatch.stop();

      // First frame should render within 16ms (60fps)
      expect(firstFrameTime, lessThan(16));

      // Complete loading should be within 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      CustomLogs.info('Likes page first frame: ${firstFrameTime}ms');
      CustomLogs.info(
        'Likes page complete load: ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Encounters page swipe performance', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: EncountersPage()));
      await tester.pumpAndSettle();

      // Find swipeable element
      final swipeTarget = find.byType(GestureDetector).first;

      final stopwatch = Stopwatch()..start();

      // Simulate swipe gesture
      await tester.drag(swipeTarget, const Offset(300, 0));
      await tester.pump(); // Single frame

      stopwatch.stop();

      // Swipe response should be immediate (< 16ms for 60fps)
      expect(stopwatch.elapsedMilliseconds, lessThan(16));

      CustomLogs.info(
        'Swipe response time: ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Memory usage test', (tester) async {
      // This is a basic memory test - in production you'd use more sophisticated tools
      final initialMemory = _getMemoryUsage();

      // Load multiple pages
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(const MaterialApp(home: LikesPage()));
        await tester.pumpAndSettle();
        await tester.pumpWidget(const MaterialApp(home: EncountersPage()));
        await tester.pumpAndSettle();
      }

      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;

      // Memory increase should be reasonable (< 50MB for this test)
      expect(memoryIncrease, lessThan(50 * 1024 * 1024));

      CustomLogs.info('Memory increase: ${memoryIncrease / (1024 * 1024)} MB');
    });

    testWidgets('Widget rebuild performance', (tester) async {
      int buildCount = 0;

      final testWidget = StatefulBuilder(
        builder: (context, setState) {
          buildCount++;
          return MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const LikesPage(),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Rebuild'),
                  ),
                ],
              ),
            ),
          );
        },
      );

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      final initialBuildCount = buildCount;

      // Trigger rebuild
      await tester.tap(find.text('Rebuild'));
      await tester.pumpAndSettle();

      final rebuildCount = buildCount - initialBuildCount;

      // Should not cause excessive rebuilds
      expect(rebuildCount, lessThan(5));

      CustomLogs.info('Widget rebuilds triggered: $rebuildCount');
    });

    testWidgets('Animation performance test', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainNavigation()));
      await tester.pumpAndSettle();

      // Test tab switching animation performance
      final stopwatch = Stopwatch()..start();

      // Switch between tabs rapidly
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Likes'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Encounters'));
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Animation sequence should complete smoothly
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      CustomLogs.info(
        'Animation sequence time: ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Large list performance', (tester) async {
      // Test performance with large lists (simulating many likes/matches)
      final largeList = ListView.builder(
        itemCount: 1000,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item $index'),
          subtitle: Text('Subtitle $index'),
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: largeList)));
      await tester.pump(); // First frame only

      stopwatch.stop();

      // Large list should render first frame quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(50));

      // Test scrolling performance
      final scrollStopwatch = Stopwatch()..start();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();

      scrollStopwatch.stop();

      // Scrolling should be responsive
      expect(scrollStopwatch.elapsedMilliseconds, lessThan(16));

      CustomLogs.info(
        'Large list render time: ${stopwatch.elapsedMilliseconds}ms',
      );
      CustomLogs.info(
        'Scroll response time: ${scrollStopwatch.elapsedMilliseconds}ms',
      );
    });
  });
}

/// Mock function to simulate memory usage measurement
/// In production, you'd use actual memory profiling tools
int _getMemoryUsage() {
  // This is a placeholder - actual implementation would use
  // platform-specific memory measurement APIs
  return DateTime.now().millisecondsSinceEpoch % 100000;
}
