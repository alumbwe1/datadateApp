import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:ui';
import 'package:video_player/video_player.dart';
import '../../../encounters/domain/entities/profile.dart';
import '../../../../core/constants/app_style.dart';
import '../controllers/reels_video_controller.dart';

/// Optimized video player widget with keep-alive to prevent rebuilds
/// Uses pre-initialized controllers for instant playback
class OptimizedReelVideoPlayer extends StatefulWidget {
  final Profile profile;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onProfileTap;
  final ReelsVideoController videoController;

  const OptimizedReelVideoPlayer({
    super.key,
    required this.profile,
    required this.isActive,
    required this.onLike,
    required this.onProfileTap,
    required this.videoController,
  });

  @override
  State<OptimizedReelVideoPlayer> createState() =>
      _OptimizedReelVideoPlayerState();
}

class _OptimizedReelVideoPlayerState extends State<OptimizedReelVideoPlayer>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool _isLiked = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late AnimationController _heartOverlayController;
  late Animation<double> _heartOverlayAnimation;
  bool _showHeartOverlay = false;

  @override
  bool get wantKeepAlive => true; // Prevent widget rebuilds

  @override
  void initState() {
    super.initState();

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _heartOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heartOverlayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartOverlayController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _heartOverlayController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _showHeartOverlay = true;
      }
    });

    if (_isLiked) {
      HapticFeedback.heavyImpact();

      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });

      _heartOverlayController.forward().then((_) {
        _heartOverlayController.reverse();
        if (mounted) {
          setState(() => _showHeartOverlay = false);
        }
      });

      widget.onLike();
    }
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    widget.videoController.togglePlayPause(widget.profile.id);
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final controller = widget.videoController.getController(widget.profile.id);
    final isInitialized = widget.videoController.isInitialized(
      widget.profile.id,
    );
    final error = widget.videoController.getError(widget.profile.id);

    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: () {
        if (!_isLiked) {
          _handleLike();
        }
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player - fills entire screen with proper aspect ratio
            if (isInitialized && controller != null && error == null)
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              )
            else if (error != null)
              _buildErrorPlaceholder(error)
            else
              _buildLoadingPlaceholder(),

            // Bottom gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),

            // Heart overlay for double-tap
            if (_showHeartOverlay)
              Center(
                child: AnimatedBuilder(
                  animation: _heartOverlayAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.5 + (_heartOverlayAnimation.value * 1.5),
                      child: Opacity(
                        opacity: 1.0 - _heartOverlayAnimation.value,
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 120,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Profile info and action buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [Expanded(child: _buildProfileInfo())],
                  ),
                ),
              ),
            ),

            // Play/Pause indicator
            if (controller != null && !controller.value.isPlaying)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return GestureDetector(
      onTap: widget.onProfileTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '${widget.profile.displayName}, ${widget.profile.age}',
                  style: appStyle(24, Colors.white, FontWeight.w900).copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: Colors.blue, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.profile.interests.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.profile.interests.take(3).map((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
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
                      child: Text(
                        interest,
                        style: appStyle(13, Colors.white, FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLiquidGlassButton(
          icon: Icons.refresh,
          iconSize: 28,
          buttonSize: 56,
          onTap: () {
            HapticFeedback.lightImpact();
            final controller = widget.videoController.getController(
              widget.profile.id,
            );
            if (controller != null) {
              controller.seekTo(Duration.zero);
            }
          },
        ),
        const SizedBox(width: 8),
        _buildLiquidGlassButton(
          icon: Icons.close_rounded,
          iconSize: 32,
          buttonSize: 64,
          onTap: () {
            HapticFeedback.mediumImpact();
          },
        ),
        const SizedBox(width: 8),
        _buildLiquidGlassButton(
          icon: Icons.star_rounded,
          iconSize: 32,
          buttonSize: 64,
          color: const Color(0xFF4A90E2),
          onTap: () {
            HapticFeedback.mediumImpact();
          },
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _likeScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _likeScaleAnimation.value,
              child: _buildLiquidGlassButton(
                icon: Iconsax.heart,
                iconSize: 32,
                buttonSize: 64,
                color: _isLiked ? const Color(0xFFFF4458) : null,
                filled: _isLiked,
                onTap: _handleLike,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildLiquidGlassButton(
          icon: IconlyBold.send,
          iconSize: 28,
          buttonSize: 56,
          color: const Color(0xFF00D4FF),
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onProfileTap();
          },
        ),
      ],
    );
  }

  Widget _buildLiquidGlassButton({
    required IconData icon,
    required double iconSize,
    required double buttonSize,
    Color? color,
    bool filled = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withValues(
            alpha: filled ? 0.25 : 0.15,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: (color ?? Colors.white).withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (color != null)
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(icon, color: color ?? Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading video...',
            style: appStyle(
              14,
              Colors.white.withValues(alpha: 0.7),
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: appStyle(
              14,
              Colors.white.withValues(alpha: 0.7),
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
