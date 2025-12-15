#!/usr/bin/env dart

import 'dart:io';

/// Script to optimize Flutter app bundle size
void main(List<String> args) async {
  print('🚀 Starting bundle optimization...\n');

  // Check if we're in a Flutter project
  if (!await File('pubspec.yaml').exists()) {
    print('❌ Error: Not in a Flutter project directory');
    exit(1);
  }

  try {
    // 1. Clean build artifacts
    print('🧹 Cleaning build artifacts...');
    await _runCommand('flutter', ['clean']);

    // 2. Get dependencies
    print('📦 Getting dependencies...');
    await _runCommand('flutter', ['pub', 'get']);

    // 3. Analyze unused dependencies
    print('🔍 Analyzing dependencies...');
    await _analyzeUnusedDependencies();

    // 4. Build optimized APK
    print('🏗️  Building optimized APK...');
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
    print('📱 Building App Bundle...');
    await _runCommand('flutter', [
      'build',
      'appbundle',
      '--release',
      '--shrink',
      '--obfuscate',
      '--split-debug-info=build/debug-info',
    ]);

    // 6. Analyze bundle size
    print('📊 Analyzing bundle size...');
    await _analyzeBundleSize();

    print('\n✅ Bundle optimization complete!');
    print('📁 Check build/app/outputs/ for optimized builds');
  } catch (e) {
    print('❌ Error during optimization: $e');
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
  print(result.stdout);
}

Future<void> _analyzeUnusedDependencies() async {
  try {
    // This would require a more sophisticated analysis
    // For now, we'll just suggest manual review
    print('💡 Tip: Review pubspec.yaml for unused dependencies');
    print('   - Remove dev dependencies not needed in production');
    print('   - Consider lighter alternatives for heavy packages');
    print('   - Use conditional imports for platform-specific code');
  } catch (e) {
    print('⚠️  Could not analyze dependencies: $e');
  }
}

Future<void> _analyzeBundleSize() async {
  try {
    final apkFile = File('build/app/outputs/flutter-apk/app-release.apk');
    final bundleFile = File('build/app/outputs/bundle/release/app-release.aab');

    if (await apkFile.exists()) {
      final apkSize = await apkFile.length();
      print('📱 APK size: ${_formatBytes(apkSize)}');
    }

    if (await bundleFile.exists()) {
      final bundleSize = await bundleFile.length();
      print('📦 App Bundle size: ${_formatBytes(bundleSize)}');
    }

    // Size recommendations
    print('\n📏 Size recommendations:');
    print('   - APK should be < 150MB for Play Store');
    print('   - App Bundle should be < 150MB for Play Store');
    print('   - Consider dynamic feature modules for large apps');
  } catch (e) {
    print('⚠️  Could not analyze bundle size: $e');
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024)
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}
