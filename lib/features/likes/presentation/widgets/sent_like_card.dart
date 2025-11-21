import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import '../../../interactions/data/models/like_model.dart';

class SentLikeCard extends StatelessWidget {
  final UserInfo userInfo;
  final ProfileData? profile;
  final String? imageUrl;
  final String createdAt;
  final VoidCallback onTap;

  const SentLikeCard({
    super.key,
    required this.userInfo,
    required this.profile,
    required this.imageUrl,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              _buildGradientOverlay(),
              _buildProfileInfo(),
              _buildPendingBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
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
      color: Colors.grey[200],
      child: Center(
        child: Text(
          userInfo.displayName[0].toUpperCase(),
          style: appStyle(48, Colors.grey[400]!, FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
          ),
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
                  '${userInfo.displayName}, ${profile?.age ?? '??'}',
                  style: appStyle(18, Colors.white, FontWeight.w700).copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
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
                Icons.schedule_rounded,
                size: 12,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                _getTimeAgo(createdAt),
                style:
                    appStyle(
                      12,
                      Colors.white.withOpacity(0.8),
                      FontWeight.w500,
                    ).copyWith(
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
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

  Widget _buildPendingBadge() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[800]!.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              color: Colors.white.withOpacity(0.9),
              size: 14,
            ),
            const SizedBox(width: 4),
            Text('Pending', style: appStyle(11, Colors.white, FontWeight.w600)),
          ],
        ),
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
