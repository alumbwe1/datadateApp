import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/utils/interest_emoji_mapper.dart';
import '../../domain/entities/profile.dart';
import '../pages/profile_details_page.dart';
import '../providers/encounters_provider.dart';
import 'crush_bottom_sheet.dart';

class ProfileCard extends ConsumerStatefulWidget {
  final Profile profile;

  const ProfileCard({super.key, required this.profile});

  @override
  ConsumerState<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<ProfileCard> {
  int _currentImageIndex = 0;

  void _nextImage() {
    if (_currentImageIndex < widget.profile.photos.length - 1) {
      setState(() => _currentImageIndex++);
    }
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      setState(() => _currentImageIndex--);
    }
  }

  void _showCrushBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => CrushBottomSheet(
        profileName: widget.profile.displayName,
        profilePhoto: widget.profile.photos.first,
      ),
    );
  }

  Future<void> _navigateToDetails() async {
    // Record profile view before navigating
    await ref
        .read(encountersProvider.notifier)
        .recordProfileView(widget.profile.id);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileDetailsPage(profile: widget.profile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety check for empty photos
    if (widget.profile.photos.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: Icon(Icons.person_outline, size: 120, color: Colors.grey),
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: () => _showCrushBottomSheet(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Profile Image with tap navigation
                GestureDetector(
                  onTapUp: (details) {
                    if (widget.profile.photos.length <= 1) return;

                    final width = context.size?.width ?? 0;
                    if (details.localPosition.dx < width / 2) {
                      _previousImage();
                    } else {
                      _nextImage();
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: CachedNetworkImage(
                      key: ValueKey(_currentImageIndex),
                      imageUrl: widget.profile.photos[_currentImageIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.grey[300]),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.grey[300]!, Colors.grey[200]!],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 120,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Image indicators (minimalist style)
                if (widget.profile.photos.length > 1)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: List.generate(widget.profile.photos.length, (
                        index,
                      ) {
                        final isActive = index == _currentImageIndex;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 3,
                            margin: EdgeInsets.only(
                              right: index < widget.profile.photos.length - 1
                                  ? 6
                                  : 0,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                // Match Score Badge
                if (widget.profile.matchScore != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getMatchScoreGradient(
                            widget.profile.matchScore!,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${widget.profile.matchScore}%',
                            style: appStyle(
                              12.sp,
                              Colors.white,
                              FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Cleaner gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 280.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Profile Info Section
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name, age with arrow button
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _navigateToDetails,
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${widget.profile.displayName}, ${widget.profile.age}',
                                        style:
                                            appStyle(
                                              24.sp,
                                              Colors.white,
                                              FontWeight.w900,
                                            ).copyWith(
                                              letterSpacing: -0.3,
                                              height: 1.2,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    // Verification badge
                                    Icon(
                                      Icons.verified,
                                      color: Colors.blue[400],
                                      size: 22.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    // University logo
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4.r),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.profile.universityLogo,
                                        width: 22.w,
                                        height: 22.w,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                              Icons.school_rounded,
                                              size: 22.sp,
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: _navigateToDetails,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Course and Intent in a row
                        Row(
                          children: [
                            // Course badge
                            if (widget.profile.course != null)
                              Flexible(
                                child: _buildInfoPill(
                                  icon: Icons.school_rounded,
                                  label: widget.profile.course!,
                                ),
                              ),
                            if (widget.profile.course != null)
                              SizedBox(width: 8.w),
                            // Intent badge
                            Flexible(
                              child: _buildInfoPill(
                                icon: Iconsax.heart,
                                label: widget.profile.intent,
                              ),
                            ),
                          ],
                        ),

                        // Interests with emojis (prioritize shared interests)
                        if (widget.profile.interests.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 6.h,
                            children: _getDisplayInterests()
                                .map(
                                  (interestData) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: interestData['isShared']
                                            ? Colors.pink.withValues(alpha: 0.6)
                                            : Colors.white.withValues(
                                                alpha: 0.3,
                                              ),
                                        width: interestData['isShared']
                                            ? 1.2.w
                                            : 0.7.w,
                                      ),
                                      color: interestData['isShared']
                                          ? Colors.pink.withValues(alpha: 0.15)
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          InterestEmojiMapper.getEmoji(
                                            interestData['interest'],
                                          ),
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          interestData['interest'],
                                          style: appStyle(
                                            12.sp,
                                            Colors.white,
                                            FontWeight.w600,
                                          ).copyWith(letterSpacing: 0.1),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        SizedBox(height: 60.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.95), size: 14.sp),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              style: appStyle(
                13.sp,
                Colors.white,
                FontWeight.w600,
              ).copyWith(letterSpacing: -0.1, height: 1.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getMatchScoreGradient(int score) {
    if (score >= 75) {
      return [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]; // Green
    } else if (score >= 50) {
      return [const Color(0xFFFF9800), const Color(0xFFFFB74D)]; // Orange
    } else {
      return [const Color(0xFF9E9E9E), const Color(0xFFBDBDBD)]; // Grey
    }
  }

  List<Map<String, dynamic>> _getDisplayInterests() {
    final sharedSet = widget.profile.sharedInterests.toSet();
    final displayInterests = <Map<String, dynamic>>[];

    // Add shared interests first
    for (final interest in widget.profile.sharedInterests.take(2)) {
      displayInterests.add({'interest': interest, 'isShared': true});
    }

    // Add remaining interests up to 3 total
    for (final interest in widget.profile.interests) {
      if (displayInterests.length >= 3) break;
      if (!sharedSet.contains(interest)) {
        displayInterests.add({'interest': interest, 'isShared': false});
      }
    }

    return displayInterests;
  }
}
