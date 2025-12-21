import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../interactions/data/models/like_model.dart';

class ReceivedLikeCard extends StatefulWidget {
  final UserInfo userInfo;
  final ProfileData? profile;
  final String? imageUrl;
  final String createdAt;
  final int index;
  final VoidCallback onTap;

  const ReceivedLikeCard({
    super.key,
    required this.userInfo,
    required this.profile,
    required this.imageUrl,
    required this.createdAt,
    required this.index,
    required this.onTap,
  });

  @override
  State<ReceivedLikeCard> createState() => _ReceivedLikeCardState();
}

class _ReceivedLikeCardState extends State<ReceivedLikeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      AppColors.secondaryLight,
      AppColors.warning,
      AppColors.primaryLight,
      AppColors.accentLight,
    ];
    final borderColor = colors[widget.index % colors.length];

    return GestureDetector(
      onTap: () {
        // Track received like card tap
        AnalyticsService.trackFeatureUsage(
          featureName: 'received_like_card_tap',
          parameters: {
            'user_id': widget.userInfo.id.toString(),
            'user_name': widget.userInfo.displayName,
            'has_profile_data': widget.profile != null,
            'has_image': widget.imageUrl != null,
          },
        );
        widget.onTap();
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight.withValues(alpha: 0.08),
                AppColors.primaryLight.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                blurRadius: 40,
                spreadRadius: -10,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  _buildGradientOverlay(),
                  _buildProfileInfo(),
                  _buildHeartBadge(borderColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.secondaryLight,
              ),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          widget.userInfo.displayName[0].toUpperCase(),
          style: appStyle(48, Colors.grey[500]!, FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.1),
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '${widget.userInfo.displayName}, ${widget.profile?.age ?? '??'}',
                  style: appStyle(18, Colors.white, FontWeight.w800).copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Text(
                _getTimeAgo(widget.createdAt),
                style:
                    appStyle(
                      12,
                      Colors.white.withValues(alpha: 0.9),
                      FontWeight.w600,
                    ).copyWith(
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeartBadge(Color color) {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Iconsax.heart, color: color, size: 20),
      ),
    );
  }

  String _getTimeAgo(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}
