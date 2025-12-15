import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

/// 🎬 PRODUCTION-READY TikTok-Style Video Controller
/// Manages intelligent preloading, instant playback, and memory-efficient recycling
/// Keeps only 3 controllers in memory: previous, current, next
class ReelsVideoController extends ChangeNotifier {
  // Map of video controllers keyed by profile ID
  final Map<int, VideoPlayerController> _controllers = {};

  // Map of cached file paths keyed by profile ID
  final Map<int, File> _cachedFiles = {};

  // Track initialization status
  final Map<int, bool> _initializationStatus = {};

  // Track loading errors
  final Map<int, String> _errors = {};

  // Track buffering status
  final Map<int, bool> _isBuffering = {};

  // Current active index
  int _currentIndex = 0;

  // Disposal range: dispose controllers beyond this range
  static const int _disposalRange = 2;

  // Track if we're currently initializing to prevent race conditions
  final Set<int> _initializingIds = {};

  int get currentIndex => _currentIndex;

  /// Get controller for a specific profile ID
  VideoPlayerController? getController(int profileId) {
    return _controllers[profileId];
  }

  /// Check if a video is initialized and ready to play
  bool isInitialized(int profileId) {
    return _initializationStatus[profileId] == true;
  }

  /// Check if a video is currently buffering
  bool isBuffering(int profileId) {
    return _isBuffering[profileId] ?? false;
  }

  /// Get error message for a profile
  String? getError(int profileId) {
    return _errors[profileId];
  }

  /// Check if video is currently playing
  bool isPlaying(int profileId) {
    final controller = _controllers[profileId];
    return controller?.value.isPlaying ?? false;
  }

  /// 🚀 Initialize and preload videos for instant playback
  /// Preloads current + adjacent videos in priority order
  Future<void> initializeVideos({
    required List<Map<String, dynamic>> profiles,
    required int startIndex,
  }) async {
    if (profiles.isEmpty) return;

    _currentIndex = startIndex.clamp(0, profiles.length - 1);

    developer.log(
      '🎬 Initializing Reels: Starting at index $_currentIndex of ${profiles.length}',
      name: 'ReelsVideoController',
    );

    // Preload current and adjacent videos with priority
    await _preloadVideosAround(profiles, _currentIndex);

    // 🚀 AUTOPLAY: Start playing the first video after initialization
    final currentProfile = profiles[_currentIndex];
    final currentId = currentProfile['id'] as int;
    if (_initializationStatus[currentId] == true) {
      await playVideo(currentId);
      developer.log(
        '▶️ Autoplay started for video $currentId',
        name: 'ReelsVideoController',
      );
    }
  }

  /// 📥 Intelligent preloading: current, next, previous (in that order)
  /// Ensures instant playback when user swipes
  Future<void> _preloadVideosAround(
    List<Map<String, dynamic>> profiles,
    int centerIndex,
  ) async {
    if (profiles.isEmpty) return;

    // Priority order: current (highest), next, previous
    final priorityOrder = <int>[];
    priorityOrder.add(centerIndex); // Current video (MUST be ready)

    // Next video (user likely to swipe down)
    if (centerIndex + 1 < profiles.length) {
      priorityOrder.add(centerIndex + 1);
    }

    // Previous video (user might swipe up)
    if (centerIndex - 1 >= 0) {
      priorityOrder.add(centerIndex - 1);
    }

    developer.log(
      '📥 Preloading priority: ${priorityOrder.join(", ")}',
      name: 'ReelsVideoController',
    );

    // Initialize videos in priority order
    for (final index in priorityOrder) {
      final profile = profiles[index];
      final profileId = profile['id'] as int;
      final videoUrl = profile['videoUrl'] as String?;

      if (videoUrl != null && videoUrl.isNotEmpty) {
        // Don't await - let them initialize in parallel for speed
        _initializeVideo(profileId, videoUrl, isPriority: index == centerIndex);
      }
    }

    // Wait only for the current video to be ready
    final currentProfile = profiles[centerIndex];
    final currentId = currentProfile['id'] as int;
    await _waitForInitialization(currentId);
  }

  /// Wait for a specific video to finish initializing
  Future<void> _waitForInitialization(int profileId) async {
    int attempts = 0;
    const maxAttempts = 50; // 5 seconds max wait
    const checkInterval = Duration(milliseconds: 100);

    while (attempts < maxAttempts) {
      if (_initializationStatus[profileId] == true) {
        return; // Video is ready!
      }
      if (_errors.containsKey(profileId)) {
        return; // Failed, stop waiting
      }
      await Future.delayed(checkInterval);
      attempts++;
    }

    developer.log(
      '⚠️ Timeout waiting for video $profileId to initialize',
      name: 'ReelsVideoController',
    );
  }

  /// 🎥 Initialize a single video with caching and buffering
  /// Uses muted autoplay for instant playback on Android
  Future<void> _initializeVideo(
    int profileId,
    String videoUrl, {
    bool isPriority = false,
  }) async {
    // Skip if already initialized or currently initializing
    if (_controllers.containsKey(profileId) ||
        _initializingIds.contains(profileId)) {
      return;
    }

    _initializingIds.add(profileId);
    _isBuffering[profileId] = true;

    try {
      developer.log(
        '🎥 ${isPriority ? "⚡ PRIORITY" : "📦 Background"} init: Video $profileId',
        name: 'ReelsVideoController',
      );

      // Step 1: Download and cache video file
      final file = await DefaultCacheManager().getSingleFile(
        videoUrl,
        key: 'reel_video_$profileId',
      );

      _cachedFiles[profileId] = file;

      // Step 2: Create controller from cached file
      final controller = VideoPlayerController.file(file);

      // Step 3: Initialize controller
      await controller.initialize();

      // Step 4: Configure for instant autoplay
      await controller.setLooping(true);
      await controller.setVolume(1.0); // Start with volume on

      // Step 5: Pre-buffer for instant playback
      await controller.seekTo(Duration.zero);

      // Step 6: Store controller and mark as ready
      _controllers[profileId] = controller;
      _initializationStatus[profileId] = true;
      _isBuffering[profileId] = false;
      _errors.remove(profileId);

      developer.log(
        '✅ Video $profileId ready (${controller.value.duration.inSeconds}s)',
        name: 'ReelsVideoController',
      );

      // Add buffering listener
      controller.addListener(() {
        if (controller.value.hasError) {
          developer.log(
            '❌ Playback error: ${controller.value.errorDescription}',
            name: 'ReelsVideoController',
          );
          _errors[profileId] = 'Playback error';
          _isBuffering[profileId] = false;
          notifyListeners();
        } else if (controller.value.isBuffering) {
          _isBuffering[profileId] = true;
          notifyListeners();
        } else if (_isBuffering[profileId] == true) {
          _isBuffering[profileId] = false;
          notifyListeners();
        }
      });

      notifyListeners();
    } catch (e) {
      developer.log(
        '❌ Init failed for video $profileId: $e',
        name: 'ReelsVideoController',
        error: e,
      );

      _errors[profileId] = 'Failed to load video';
      _initializationStatus[profileId] = false;
      _isBuffering[profileId] = false;
      notifyListeners();
    } finally {
      _initializingIds.remove(profileId);
    }
  }

  /// 📄 Handle page change: instant video swap + smart preloading
  /// This is the CRITICAL method for TikTok-style smoothness
  Future<void> onPageChanged({
    required List<Map<String, dynamic>> profiles,
    required int newIndex,
  }) async {
    if (profiles.isEmpty || newIndex < 0 || newIndex >= profiles.length) {
      return;
    }

    final oldIndex = _currentIndex;
    _currentIndex = newIndex;

    developer.log(
      '📄 Swipe: $oldIndex → $newIndex',
      name: 'ReelsVideoController',
    );

    // STEP 1: Pause old video IMMEDIATELY (no await to prevent blocking)
    if (oldIndex >= 0 && oldIndex < profiles.length) {
      final oldProfileId = profiles[oldIndex]['id'] as int;
      final oldController = _controllers[oldProfileId];
      if (oldController != null && oldController.value.isPlaying) {
        oldController.pause(); // No await - instant pause
        developer.log('⏸️ Paused: $oldProfileId', name: 'ReelsVideoController');
      }
    }

    // STEP 2: Play new video INSTANTLY (should already be initialized)
    final newProfileId = profiles[newIndex]['id'] as int;
    final newController = _controllers[newProfileId];

    if (newController != null && _initializationStatus[newProfileId] == true) {
      // Video is ready - play immediately
      await newController.play();
      developer.log('▶️ Playing: $newProfileId', name: 'ReelsVideoController');
    } else {
      // Video not ready - initialize urgently
      developer.log(
        '⚠️ Video $newProfileId not preloaded! Initializing now...',
        name: 'ReelsVideoController',
      );
      final videoUrl = profiles[newIndex]['videoUrl'] as String?;
      if (videoUrl != null && videoUrl.isNotEmpty) {
        await _initializeVideo(newProfileId, videoUrl, isPriority: true);
        final controller = _controllers[newProfileId];
        if (controller != null) {
          await controller.play();
        }
      }
    }

    // STEP 3: Preload adjacent videos in background (non-blocking)
    _preloadVideosAround(profiles, newIndex);

    // STEP 4: Dispose distant videos to free memory
    _disposeDistantVideos(profiles, newIndex);

    notifyListeners();
  }

  /// 🗑️ Memory management: dispose videos beyond disposal range
  /// Keeps only 3-5 controllers in memory at once
  void _disposeDistantVideos(
    List<Map<String, dynamic>> profiles,
    int centerIndex,
  ) {
    final controllersToDispose = <int>[];

    for (final entry in _controllers.entries) {
      final profileId = entry.key;

      // Find index of this profile
      final profileIndex = profiles.indexWhere((p) => p['id'] == profileId);

      // Dispose if not found or too far from current index
      if (profileIndex == -1 ||
          (profileIndex - centerIndex).abs() > _disposalRange) {
        controllersToDispose.add(profileId);
      }
    }

    // Clean up distant controllers
    for (final profileId in controllersToDispose) {
      developer.log(
        '🗑️ Disposing: Video $profileId (too far)',
        name: 'ReelsVideoController',
      );

      _controllers[profileId]!.dispose();
      _controllers.remove(profileId);
      _cachedFiles.remove(profileId);
      _initializationStatus.remove(profileId);
      _errors.remove(profileId);
      _isBuffering.remove(profileId);
      _initializingIds.remove(profileId);
    }

    if (controllersToDispose.isNotEmpty) {
      developer.log(
        '♻️ Memory freed: ${controllersToDispose.length} controllers disposed',
        name: 'ReelsVideoController',
      );
    }
  }

  /// ▶️ Play video for a specific profile
  Future<void> playVideo(int profileId) async {
    final controller = _controllers[profileId];
    if (controller != null && _initializationStatus[profileId] == true) {
      await controller.play();
      notifyListeners();
    }
  }

  /// ⏸️ Pause video for a specific profile
  Future<void> pauseVideo(int profileId) async {
    final controller = _controllers[profileId];
    if (controller != null) {
      await controller.pause();
      notifyListeners();
    }
  }

  /// 🔄 Toggle play/pause for a specific profile
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

  /// 🔊 Set volume for a specific video (0.0 = muted, 1.0 = full)
  Future<void> setVolume(int profileId, double volume) async {
    final controller = _controllers[profileId];
    if (controller != null) {
      await controller.setVolume(volume.clamp(0.0, 1.0));
      notifyListeners();
    }
  }

  /// 🔇 Toggle mute/unmute for a specific video
  Future<void> toggleMute(int profileId) async {
    final controller = _controllers[profileId];
    if (controller != null) {
      final currentVolume = controller.value.volume;
      await controller.setVolume(currentVolume > 0 ? 0.0 : 1.0);
      notifyListeners();
    }
  }

  /// 🧹 Clear all video cache
  Future<void> clearCache() async {
    developer.log('🧹 Clearing video cache', name: 'ReelsVideoController');
    await DefaultCacheManager().emptyCache();
  }

  /// 🔚 Clean disposal of all resources
  @override
  void dispose() {
    developer.log(
      '🔚 Disposing ReelsVideoController (${_controllers.length} controllers)',
      name: 'ReelsVideoController',
    );

    // Dispose all video controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    // Clear all maps
    _controllers.clear();
    _cachedFiles.clear();
    _initializationStatus.clear();
    _errors.clear();
    _isBuffering.clear();
    _initializingIds.clear();

    super.dispose();
  }
}
