import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../encounters/presentation/providers/encounters_provider.dart';
import '../../../encounters/presentation/pages/profile_details_page.dart';
import '../../../encounters/presentation/pages/match_page.dart';
import '../providers/reels_provider.dart';
import '../widgets/optimized_reel_video_player.dart';
import '../controllers/reels_video_controller.dart';

class ReelsPage extends ConsumerStatefulWidget {
  const ReelsPage({super.key});

  @override
  ConsumerState<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends ConsumerState<ReelsPage> {
  final PageController _pageController = PageController();
  late final ReelsVideoController _videoController;
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = ReelsVideoController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(reelsProvider.notifier).loadReels();
      _initializeVideos();
    });
  }

  void _initializeVideos() {
    final reelsState = ref.read(reelsProvider);
    if (reelsState.profiles.isNotEmpty && !_isInitialized) {
      _isInitialized = true;

      // Convert profiles to map format for video controller
      final profileMaps = reelsState.profiles
          .map((profile) => {'id': profile.id, 'videoUrl': profile.videoUrl})
          .toList();

      _videoController.initializeVideos(profiles: profileMaps, startIndex: 0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _handleLike(
    int profileId,
    String profileName,
    String profilePhoto,
  ) async {
    try {
      final matchInfo = await ref
          .read(encountersProvider.notifier)
          .likeProfile(profileId.toString());

      if (mounted) {
        if (matchInfo != null && matchInfo['matched'] == true) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MatchPage(
                    profileName: profileName,
                    profilePhoto: profilePhoto,
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        } else {
          CustomSnackbar.show(
            context,
            message: 'Like sent!',
            type: SnackbarType.success,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        if (errorMessage.contains('already liked')) {
          CustomSnackbar.show(
            context,
            message: 'You\'ve already liked this profile',
            type: SnackbarType.warning,
            duration: const Duration(seconds: 2),
          );
        } else {
          CustomSnackbar.show(
            context,
            message: 'Failed to send like',
            type: SnackbarType.error,
            duration: const Duration(seconds: 2),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reelsState = ref.watch(reelsProvider);
    final profiles = reelsState.profiles;

    // Initialize videos when profiles are loaded
    if (profiles.isNotEmpty && !_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeVideos();
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Main content
          if (reelsState.isLoading)
            _buildShimmerLoading()
          else if (reelsState.error != null)
            _buildErrorState(reelsState.error!)
          else if (profiles.isEmpty)
            _buildEmptyState()
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) async {
                setState(() => _currentIndex = index);

                // Record profile view
                ref
                    .read(reelsProvider.notifier)
                    .recordProfileView(profiles[index].id);

                // Handle video playback and preloading
                final profileMaps = profiles
                    .map(
                      (profile) => {
                        'id': profile.id,
                        'videoUrl': profile.videoUrl,
                      },
                    )
                    .toList();

                await _videoController.onPageChanged(
                  profiles: profileMaps,
                  newIndex: index,
                );
              },
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return OptimizedReelVideoPlayer(
                  profile: profile,
                  isActive: index == _currentIndex,
                  videoController: _videoController,
                  onLike: () => _handleLike(
                    profile.id,
                    profile.displayName,
                    profile.photos.isNotEmpty ? profile.photos.first : '',
                  ),
                  onProfileTap: () async {
                    await ref
                        .read(reelsProvider.notifier)
                        .recordProfileView(profile.id);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileDetailsPage(profile: profile),
                        ),
                      );
                    }
                  },
                );
              },
            ),

          // Close button and title (top)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reels',
                              style: appStyle(18, Colors.white, FontWeight.w700)
                                  .copyWith(
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Animated gradient shimmer
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade900,
                  Colors.grey.shade800,
                  Colors.grey.shade900,
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing play icon
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.2),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.play_circle_filled,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Loading Reels...',
                  style: appStyle(18, Colors.white70, FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated empty icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.video_library_outlined,
                          size: 70,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'No Reels Yet',
                style: appStyle(
                  32,
                  Colors.white,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Check back soon for new\nvideo profiles to discover',
                style: appStyle(
                  16,
                  Colors.white.withValues(alpha: 0.6),
                  FontWeight.w400,
                ).copyWith(height: 1.6, letterSpacing: -0.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(reelsProvider.notifier).loadReels();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Refresh',
                        style: appStyle(18, Colors.black, FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated error icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 70,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Oops!',
                style: appStyle(
                  32,
                  Colors.white,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: appStyle(
                  16,
                  Colors.white.withValues(alpha: 0.6),
                  FontWeight.w400,
                ).copyWith(height: 1.6, letterSpacing: -0.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(reelsProvider.notifier).loadReels();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Try Again',
                        style: appStyle(18, Colors.black, FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
