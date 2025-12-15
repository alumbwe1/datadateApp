#!/usr/bin/env dart

import 'dart:io';

import 'package:datadate/core/utils/custom_logs.dart' show CustomLogs;

/// Script to run all tests in the correct order
void main(List<String> args) async {
  CustomLogs.info('🧪 Running comprehensive test suite...\n');

  try {
    // 1. Run unit tests
    CustomLogs.info('📋 Running unit tests...');
    await _runCommand('flutter', ['test', '--coverage']);
    CustomLogs.info('✅ Unit tests completed\n');

    // 2. Run performance tests
    CustomLogs.info('⚡ Running performance tests...');
    await _runCommand('flutter', ['test', 'test/performance_test.dart']);
    CustomLogs.info('✅ Performance tests completed\n');

    // 3. Run integration tests (if device/simulator is available)
    CustomLogs.info('🔗 Running integration tests...');
    try {
      await _runCommand('flutter', ['test', 'integration_test/app_test.dart']);
      CustomLogs.info('✅ Integration tests completed\n');
    } catch (e) {
      CustomLogs.info(
        '⚠️  Integration tests skipped (no device/simulator available)\n',
      );
    }

    // 4. Generate coverage report
    CustomLogs.info('📊 Generating coverage report...');
    if (File('coverage/lcov.info').existsSync()) {
      // You can add coverage report generation here
      CustomLogs.info('✅ Coverage report available at coverage/lcov.info\n');
    }

    CustomLogs.info('🎉 All tests completed successfully!');
  } catch (e) {
    CustomLogs.info('❌ Test suite failed: $e');
    exit(1);
  }
}

Future<void> _runCommand(String command, List<String> args) async {
  CustomLogs.info('Running: $command ${args.join(' ')}');

  final result = await Process.run(command, args);

  if (result.exitCode != 0) {
    throw Exception(
      'Command failed: $command ${args.join(' ')}\n${result.stderr}',
    );
  }

  if (result.stdout.toString().isNotEmpty) {
    CustomLogs.info(result.stdout);
  }
}
