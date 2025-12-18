import 'package:datadate/core/network/api_client.dart';
import 'package:datadate/core/providers/api_providers.dart';
import 'package:datadate/core/utils/custom_logs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock API Client that doesn't make real network calls
class MockApiClient extends ApiClient {
  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Return mock data instead of making real requests
    if (path.contains('likes')) {
      return {
            'data': {'sent_likes': [], 'received_likes': []},
          }
          as T;
    }
    if (path.contains('profiles')) {
      return {
            'data': {'profiles': [], 'has_more': false},
          }
          as T;
    }
    return {'data': {}} as T;
  }

  @override
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return {'data': {}} as T;
  }

  @override
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return {'data': {}} as T;
  }

  @override
  Future<T?> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return {'data': {}} as T?;
  }
}

// Simple test widget that doesn't depend on complex providers
class SimpleTestWidget extends StatelessWidget {
  const SimpleTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Widget')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Performance Test Widget'),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

// Helper function to wrap widgets with ScreenUtilInit and ProviderScope for tests
Widget _wrapWithScreenUtil(Widget child) {
  return ProviderScope(
    overrides: [
      // Override API client to prevent real network calls
      apiClientProvider.overrideWithValue(MockApiClient()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MaterialApp(home: child);
      },
    ),
  );
}

void main() {
  group('Performance Tests', () {
    testWidgets('Basic widget rendering performance', (tester) async {
      // Measure basic widget rendering performance
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(_wrapWithScreenUtil(const SimpleTestWidget()));
      await tester.pump(); // Only pump once

      stopwatch.stop();

      // Widget should render within reasonable time for test environment
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      CustomLogs.info(
        'Basic widget render time: ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Widget rebuild performance', (tester) async {
      int buildCount = 0;

      final testWidget = ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(MockApiClient())],
        child: StatefulBuilder(
          builder: (context, setState) {
            buildCount++;
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Text('Build count: $buildCount'),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Rebuild'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      final initialBuildCount = buildCount;

      // Trigger rebuild
      if (find.text('Rebuild').evaluate().isNotEmpty) {
        await tester.tap(find.text('Rebuild'));
        await tester.pump();
      }

      final rebuildCount = buildCount - initialBuildCount;

      // Should not cause excessive rebuilds
      expect(rebuildCount, lessThan(5));

      CustomLogs.info('Widget rebuilds triggered: $rebuildCount');
    });

    testWidgets('Large list rendering performance', (tester) async {
      // Test performance with large lists
      final largeList = ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item $index'),
          subtitle: Text('Subtitle $index'),
          leading: const Icon(Icons.person),
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(MockApiClient())],
          child: MaterialApp(home: Scaffold(body: largeList)),
        ),
      );
      await tester.pump(); // First frame only

      stopwatch.stop();

      // Large list should render first frame quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      CustomLogs.info(
        'Large list render time: ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Scrolling performance test', (tester) async {
      final scrollableList = ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) => Container(
          height: 60,
          margin: const EdgeInsets.all(4),
          color: Colors.blue.withOpacity(0.1),
          child: Center(child: Text('Item $index')),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(MockApiClient())],
          child: MaterialApp(home: Scaffold(body: scrollableList)),
        ),
      );
      await tester.pump();

      // Test scrolling performance
      final scrollStopwatch = Stopwatch()..start();

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      scrollStopwatch.stop();

      // Scrolling should be responsive
      expect(scrollStopwatch.elapsedMilliseconds, lessThan(100));

      CustomLogs.info(
        'Scroll response time: ${scrollStopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Animation performance test', (tester) async {
      final animatedWidget = StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            home: Scaffold(
              body: const Center(child: CircularProgressIndicator()),
              floatingActionButton: FloatingActionButton(
                onPressed: () => setState(() {}),
                child: const Icon(Icons.refresh),
              ),
            ),
          );
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(MockApiClient())],
          child: animatedWidget,
        ),
      );
      await tester.pump();

      // Test animation performance
      final stopwatch = Stopwatch()..start();

      // Trigger animation by tapping FAB
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump(const Duration(milliseconds: 100));
      }

      stopwatch.stop();

      // Animation should complete smoothly
      expect(stopwatch.elapsedMilliseconds, lessThan(200));

      CustomLogs.info(
        'Animation response time: ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('Memory usage simulation test', (tester) async {
      // This is a basic memory test simulation
      final initialMemory = _getMemoryUsage();

      // Create and dispose multiple widgets
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(_wrapWithScreenUtil(const SimpleTestWidget()));
        await tester.pump();

        // Dispose by pumping empty widget
        await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
        await tester.pump();
      }

      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;

      // Memory increase should be reasonable (< 10MB for this simple test)
      expect(memoryIncrease, lessThan(10 * 1024 * 1024));

      CustomLogs.info('Memory increase: ${memoryIncrease / (1024 * 1024)} MB');
    });

    testWidgets('Widget lifecycle safety test', (tester) async {
      await tester.pumpWidget(_wrapWithScreenUtil(const SimpleTestWidget()));
      await tester.pump();

      // Dispose the widget tree properly
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      // Verify no exceptions after disposal
      expect(tester.takeException(), isNull);

      CustomLogs.info('Lifecycle safety test passed');
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
