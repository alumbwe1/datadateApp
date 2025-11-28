import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_style.dart';
import '../../../encounters/domain/entities/profile.dart';

class ReelVideoPlayer extends StatefulWidget {
  final Profile profile;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onProfileTap;

  const ReelVideoPlayer({
    super.key,
    required this.profile,
    required this.isActive,
    required this.onLike,
    required this.onProfileTap,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLiked = false;
  bool _showPlayPause = false;

  @override
  void initState() {
    super.initState();
    if (widget.profile.videoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller?.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller?.pause();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.profile.videoUrl == null) return;

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.profile.videoUrl!),
    );

    await _controller!.initialize();
    _controller!.setLooping(true);

    if (mounted) {
      setState(() => _isInitialized = true);
      if (widget.isActive) {
        _controller!.play();
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      _showPlayPause = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showPlayPause = false);
      }
    });
  }

  void _handleLike() {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      widget.onLike();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profile.videoUrl == null) {
      return _buildNoVideoPlaceholder();
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          if (_isInitialized && _controller != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Gradient overlays
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Play/Pause indicator
          if (_showPlayPause)
            Center(
              child: AnimatedOpacity(
                opacity: _showPlayPause ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller?.value.isPlaying ?? false
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Profile info (bottom left)
          Positioned(
            bottom: 100,
            left: 16,
            right: 100,
            child: GestureDetector(
              onTap: widget.onProfileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${widget.profile.displayName}, ${widget.profile.age}',
                        style: appStyle(24, Colors.white, FontWeight.w900)
                            .copyWith(
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.profile.universityName,
                              style: appStyle(
                                12,
                                Colors.white,
                                FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.profile.bio != null &&
                      widget.profile.bio!.isNotEmpty)
                    Text(
                      widget.profile.bio!,
                      style: appStyle(14, Colors.white, FontWeight.w400)
                          .copyWith(
                            height: 1.4,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.profile.interests.take(3).map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: appStyle(12, Colors.white, FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons (right side)
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                // Profile picture
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: widget.profile.photos.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.profile.photos.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: widget.profile.photos.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Like button
                _buildActionButton(
                  icon: _isLiked ? Iconsax.heart : Iconsax.heart,
                  label: 'Like',
                  onTap: _handleLike,
                  color: _isLiked ? Colors.red : Colors.white,
                ),
                const SizedBox(height: 24),

                // Comment button
                _buildActionButton(
                  icon: Iconsax.message,
                  label: 'Chat',
                  onTap: widget.onProfileTap,
                ),
                const SizedBox(height: 24),

                // Share button
                _buildActionButton(
                  icon: Iconsax.send_2,
                  label: 'Share',
                  onTap: () {
                    // TODO: Implement share
                  },
                ),
              ],
            ),
          ),

          // Video progress indicator
          if (_isInitialized && _controller != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: false,
                colors: VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white.withValues(alpha: 0.3),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: appStyle(12, Colors.white, FontWeight.w600).copyWith(
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVideoPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(
          Icons.videocam_off_outlined,
          size: 80,
          color: Colors.white54,
        ),
      ),
    );
  }
}
