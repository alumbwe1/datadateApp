#!/usr/bin/env dart

import 'dart:io';

import 'package:datadate/core/utils/custom_logs.dart';

/// Script to optimize Flutter app bundle size
void main(List<String> args) async {
  CustomLogs.info('🚀 Starting bundle optimization...\n');

  // Check if we're in a Flutter project
  if (!await File('pubspec.yaml').exists()) {
    CustomLogs.info('❌ Error: Not in a Flutter project directory');
    exit(1);
  }

  try {
    // 1. Clean build artifacts
    CustomLogs.info('🧹 Cleaning build artifacts...');
    await _runCommand('flutter', ['clean']);

    // 2. Get dependencies
    CustomLogs.info('📦 Getting dependencies...');
    await _runCommand('flutter', ['pub', 'get']);

    // 3. Analyze unused dependencies
    CustomLogs.info('🔍 Analyzing dependencies...');
    await _analyzeUnusedDependencies();

    // 4. Build optimized APK
    CustomLogs.info('🏗️  Building optimized APK...');
    await _runCommand('flutter', [
      'build',
      'apk',
      '--release',
      '--shrink',
      '--obfuscate',
      '--split-debug-info=build/debug-info',
      '--target-platform=android-arm64',
    ]);

    // 5. Build App Bundle
    CustomLogs.info('📱 Building App Bundle...');
    await _runCommand('flutter', [
      'build',
      'appbundle',
      '--release',
      '--shrink',
      '--obfuscate',
      '--split-debug-info=build/debug-info',
    ]);

    // 6. Analyze bundle size
    CustomLogs.info('📊 Analyzing bundle size...');
    await _analyzeBundleSize();

    CustomLogs.info('\n✅ Bundle optimization complete!');
    CustomLogs.info('📁 Check build/app/outputs/ for optimized builds');
  } catch (e) {
    CustomLogs.info('❌ Error during optimization: $e');
    exit(1);
  }
}

Future<void> _runCommand(String command, List<String> args) async {
  final result = await Process.run(command, args);
  if (result.exitCode != 0) {
    throw Exception(
      'Command failed: $command ${args.join(' ')}\n${result.stderr}',
    );
  }
  CustomLogs.info(result.stdout);
}

Future<void> _analyzeUnusedDependencies() async {
  try {
    // This would require a more sophisticated analysis
    // For now, we'll just suggest manual review
    CustomLogs.info('💡 Tip: Review pubspec.yaml for unused dependencies');
    CustomLogs.info('   - Remove dev dependencies not needed in production');
    CustomLogs.info('   - Consider lighter alternatives for heavy packages');
    CustomLogs.info('   - Use conditional imports for platform-specific code');
  } catch (e) {
    CustomLogs.info('⚠️  Could not analyze dependencies: $e');
  }
}

Future<void> _analyzeBundleSize() async {
  try {
    final apkFile = File('build/app/outputs/flutter-apk/app-release.apk');
    final bundleFile = File('build/app/outputs/bundle/release/app-release.aab');

    if (await apkFile.exists()) {
      final apkSize = await apkFile.length();
      CustomLogs.info('📱 APK size: ${_formatBytes(apkSize)}');
    }

    if (await bundleFile.exists()) {
      final bundleSize = await bundleFile.length();
      CustomLogs.info('📦 App Bundle size: ${_formatBytes(bundleSize)}');
    }

    // Size recommendations
    CustomLogs.info('\n📏 Size recommendations:');
    CustomLogs.info('   - APK should be < 150MB for Play Store');
    CustomLogs.info('   - App Bundle should be < 150MB for Play Store');
    CustomLogs.info('   - Consider dynamic feature modules for large apps');
  } catch (e) {
    CustomLogs.info('⚠️  Could not analyze bundle size: $e');
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024)
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
