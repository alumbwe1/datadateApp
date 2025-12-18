// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:datadate/core/network/api_client.dart';
import 'package:datadate/core/providers/api_providers.dart';
import 'package:datadate/core/widgets/main_navigation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock API Client for testing
class MockApiClient extends ApiClient {
  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
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

// Helper function to wrap app with ScreenUtilInit for tests
Widget _wrapWithScreenUtil(Widget child) {
  return ProviderScope(
    overrides: [apiClientProvider.overrideWithValue(MockApiClient())],
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
  testWidgets('Basic widget renders without errors', (
    WidgetTester tester,
  ) async {
    // Test a simple widget instead of the full app
    const testWidget = Scaffold(body: Center(child: Text('Test Widget')));

    await tester.pumpWidget(_wrapWithScreenUtil(testWidget));
    await tester.pump();

    // Verify the widget rendered
    expect(find.text('Test Widget'), findsOneWidget);

    // Verify no exceptions occurred
    expect(tester.takeException(), isNull);
  });

  testWidgets('Main navigation renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithScreenUtil(const MainNavigation()));

    // Pump a frame to let the widget initialize
    await tester.pump();

    // Verify no exceptions occurred during initialization
    expect(tester.takeException(), isNull);

    // Verify the navigation widget is present
    expect(find.byType(MainNavigation), findsOneWidget);
  });
}
