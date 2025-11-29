import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:developer' as developer;

/// Manages video caching, preloading, and controller lifecycle for TikTok-style feed
/// Ensures instant playback by preloading adjacent videos
class ReelsVideoController extends ChangeNotifier {
  // Map of video controllers keyed by profile ID
  final Map<int, VideoPlayerController> _controllers = {};

  // Map of cached file paths keyed by profile ID
  final Map<int, File> _cachedFiles = {};

  // Track initialization status
  final Map<int, bool> _initializationStatus = {};

  // Track loading errors
  final Map<int, String> _errors = {};

  // Current active index
  int _currentIndex = 0;

  // Preload range (how many videos ahead/behind to preload)
  static const int _preloadRange = 2;

  // Disposal range (dispose controllers beyond this range)
  static const int _disposalRange = 3;

  int get currentIndex => _currentIndex;

  /// Get controller for a specific profile ID
  VideoPlayerController? getController(int profileId) {
    return _controllers[profileId];
  }

  /// Check if a video is initialized
  bool isInitialized(int profileId) {
    return _initializationStatus[profileId] == true;
  }

  /// Get error message for a profile
  String? getError(int profileId) {
    return _errors[profileId];
  }

  /// Initialize and preload videos for a list of profiles
  Future<void> initializeVideos({
    required List<Map<String, dynamic>> profiles,
    required int startIndex,
  }) async {
    _currentIndex = startIndex;

    developer.log(
      '🎬 ReelsVideoController: Initializing videos starting at index $startIndex',
      name: 'ReelsVideoController',
    );

    // Preload current and adjacent videos
    await _preloadVideosAround(profiles, startIndex);
  }

  /// Preload videos around a specific index
  Future<void> _preloadVideosAround(
    List<Map<String, dynamic>> profiles,
    int centerIndex,
  ) async {
    final startIndex = (centerIndex - _preloadRange).clamp(
      0,
      profiles.length - 1,
    );
    final endIndex = (centerIndex + _preloadRange).clamp(
      0,
      profiles.length - 1,
    );

    developer.log(
      '📥 Preloading videos from index $startIndex to $endIndex',
      name: 'ReelsVideoController',
    );

    // Preload in priority order: current, next, previous, then further out
    final priorityOrder = <int>[];
    priorityOrder.add(centerIndex);

    for (int i = 1; i <= _preloadRange; i++) {
      if (centerIndex + i <= endIndex) priorityOrder.add(centerIndex + i);
      if (centerIndex - i >= startIndex) priorityOrder.add(centerIndex - i);
    }

    for (final index in priorityOrder) {
      if (index >= 0 && index < profiles.length) {
        final profile = profiles[index];
        final profileId = profile['id'] as int;
        final videoUrl = profile['videoUrl'] as String?;

        if (videoUrl != null && videoUrl.isNotEmpty) {
          await _initializeVideo(
            profileId,
            videoUrl,
            isPriority: index == centerIndex,
          );
        }
      }
    }
  }

  /// Initialize a single video with caching
  Future<void> _initializeVideo(
    int profileId,
    String videoUrl, {
    bool isPriority = false,
  }) async {
    // Skip if already initialized or in progress
    if (_controllers.containsKey(profileId)) {
      developer.log(
        '⏭️ Video $profileId already initialized, skipping',
        name: 'ReelsVideoController',
      );
      return;
    }

    try {
      developer.log(
        '🎥 ${isPriority ? "PRIORITY" : "Background"} initializing video $profileId from $videoUrl',
        name: 'ReelsVideoController',
      );

      // Step 1: Download and cache the video file
      final file = await DefaultCacheManager().getSingleFile(
        videoUrl,
        key: 'reel_video_$profileId',
      );

      _cachedFiles[profileId] = file;

      developer.log(
        '💾 Video $profileId cached at ${file.path}',
        name: 'ReelsVideoController',
      );

      // Step 2: Create controller from cached file
      final controller = VideoPlayerController.file(file);

      // Step 3: Initialize the controller
      await controller.initialize();

      // Step 4: Configure controller
      controller.setLooping(true);
      controller.setVolume(1.0);

      // Step 5: Store controller and mark as initialized
      _controllers[profileId] = controller;
      _initializationStatus[profileId] = true;
      _errors.remove(profileId);

      developer.log(
        '✅ Video $profileId initialized successfully (${controller.value.duration})',
        name: 'ReelsVideoController',
      );

      // Add error listener
      controller.addListener(() {
        if (controller.value.hasError) {
          developer.log(
            '❌ Playback error for video $profileId: ${controller.value.errorDescription}',
            name: 'ReelsVideoController',
          );
          _errors[profileId] = 'Playback error';
          notifyListeners();
        }
      });

      notifyListeners();
    } catch (e) {
      developer.log(
        '❌ Failed to initialize video $profileId: $e',
        name: 'ReelsVideoController',
        error: e,
      );

      _errors[profileId] = 'Failed to load video';
      _initializationStatus[profileId] = false;
      notifyListeners();

      // Retry logic
      await _retryInitialization(profileId, videoUrl);
    }
  }

  /// Retry video initialization on failure
  Future<void> _retryInitialization(int profileId, String videoUrl) async {
    developer.log(
      '🔄 Retrying initialization for video $profileId',
      name: 'ReelsVideoController',
    );

    try {
      // Clear cache for this video
      await DefaultCacheManager().removeFile('reel_video_$profileId');

      // Wait a bit before retrying
      await Future.delayed(const Duration(seconds: 1));

      // Retry initialization
      await _initializeVideo(profileId, videoUrl);
    } catch (e) {
      developer.log(
        '❌ Retry failed for video $profileId: $e',
        name: 'ReelsVideoController',
        error: e,
      );
    }
  }

  /// Handle page change - play new video, pause old one, preload adjacent
  Future<void> onPageChanged({
    required List<Map<String, dynamic>> profiles,
    required int newIndex,
  }) async {
    final oldIndex = _currentIndex;
    _currentIndex = newIndex;

    developer.log(
      '📄 Page changed from $oldIndex to $newIndex',
      name: 'ReelsVideoController',
    );

    // Pause old video immediately
    if (oldIndex >= 0 && oldIndex < profiles.length) {
      final oldProfileId = profiles[oldIndex]['id'] as int;
      final oldController = _controllers[oldProfileId];
      if (oldController != null && oldController.value.isPlaying) {
        await oldController.pause();
        developer.log(
          '⏸️ Paused video $oldProfileId',
          name: 'ReelsVideoController',
        );
      }
    }

    // Play new video immediately
    if (newIndex >= 0 && newIndex < profiles.length) {
      final newProfileId = profiles[newIndex]['id'] as int;
      final newController = _controllers[newProfileId];
      if (newController != null &&
          _initializationStatus[newProfileId] == true) {
        await newController.play();
        developer.log(
          '▶️ Playing video $newProfileId',
          name: 'ReelsVideoController',
        );
      }
    }

    // Preload adjacent videos in background
    _preloadVideosAround(profiles, newIndex);

    // Dispose far-away videos to save memory
    _disposeDistantVideos(profiles, newIndex);

    notifyListeners();
  }

  /// Dispose videos that are too far from current index
  void _disposeDistantVideos(
    List<Map<String, dynamic>> profiles,
    int centerIndex,
  ) {
    final controllersToDispose = <int>[];

    for (final entry in _controllers.entries) {
      final profileId = entry.key;

      // Find index of this profile
      final profileIndex = profiles.indexWhere((p) => p['id'] == profileId);

      if (profileIndex == -1 ||
          (profileIndex - centerIndex).abs() > _disposalRange) {
        controllersToDispose.add(profileId);
      }
    }

    for (final profileId in controllersToDispose) {
      developer.log(
        '🗑️ Disposing distant video $profileId',
        name: 'ReelsVideoController',
      );

      _controllers[profileId]?.dispose();
      _controllers.remove(profileId);
      _cachedFiles.remove(profileId);
      _initializationStatus.remove(profileId);
      _errors.remove(profileId);
    }
  }

  /// Play video for a specific profile
  Future<void> playVideo(int profileId) async {
    final controller = _controllers[profileId];
    if (controller != null && _initializationStatus[profileId] == true) {
      await controller.play();
      developer.log(
        '▶️ Playing video $profileId',
        name: 'ReelsVideoController',
      );
    }
  }

  /// Pause video for a specific profile
  Future<void> pauseVideo(int profileId) async {
    final controller = _controllers[profileId];
    if (controller != null) {
      await controller.pause();
      developer.log('⏸️ Paused video $profileId', name: 'ReelsVideoController');
    }
  }

  /// Toggle play/pause for a specific profile
  Future<void> togglePlayPause(int profileId) async {
    final controller = _controllers[profileId];
    if (controller != null && _initializationStatus[profileId] == true) {
      if (controller.value.isPlaying) {
        await pauseVideo(profileId);
      } else {
        await playVideo(profileId);
      }
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    developer.log('🧹 Clearing all video cache', name: 'ReelsVideoController');
    await DefaultCacheManager().emptyCache();
  }

  @override
  void dispose() {
    developer.log(
      '🔚 Disposing ReelsVideoController',
      name: 'ReelsVideoController',
    );

    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    _controllers.clear();
    _cachedFiles.clear();
    _initializationStatus.clear();
    _errors.clear();

    super.dispose();
  }
}
