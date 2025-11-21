import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_style.dart';
import '../../domain/entities/profile.dart';
import '../pages/profile_details_page.dart';
import 'crush_bottom_sheet.dart';

class ProfileCard extends StatefulWidget {
  final Profile profile;

  const ProfileCard({super.key, required this.profile});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailsPage(profile: widget.profile),
          ),
        );
      },
      onDoubleTap: () {
        _showCrushBottomSheet(context);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Profile Image with PageView for swiping
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

                // Image indicators (like Tinder)
                if (widget.profile.photos.length > 1)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(widget.profile.photos.length, (
                        index,
                      ) {
                        final isActive = index == _currentImageIndex;

                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 6,
                            margin: EdgeInsets.only(
                              right: index < widget.profile.photos.length - 1
                                  ? 8
                                  : 0,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isActive ? 0.28 : 0.15,
                                  ),
                                  blurRadius: isActive ? 6 : 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                // Gradient overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 290.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Profile Info - AT BOTTOM (Tinder style)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.85),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name, age and verification
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${widget.profile.displayName}, ${widget.profile.age}',
                                style:
                                    appStyle(
                                      21.sp,
                                      Colors.white,
                                      FontWeight.w900,
                                    ).copyWith(
                                      letterSpacing: -0.8,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          offset: const Offset(0, 2),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              color: Colors.blue[400],
                              size: 24,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: CachedNetworkImage(
                                imageUrl: widget.profile.universityLogo,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.school,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        // Course info
                        if (widget.profile.course != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 16,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      offset: const Offset(0, 1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    widget.profile.course!,
                                    style:
                                        appStyle(
                                          14,
                                          Colors.white,
                                          FontWeight.w600,
                                        ).copyWith(
                                          letterSpacing: -0.2,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              offset: const Offset(0, 1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 10.h),

                        // Container(
                        //   padding: const EdgeInsets.all(10),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white.withOpacity(0.12),
                        //     borderRadius: BorderRadius.circular(30),
                        //     border: Border.all(
                        //       color: Colors.white.withOpacity(0.2),
                        //       width: 1,
                        //     ),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.1),
                        //         blurRadius: 12,
                        //         offset: const Offset(0, 4),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Text(
                        //     widget.profile.university,
                        //     style: appStyle(15, Colors.white, FontWeight.w600)
                        //         .copyWith(
                        //           letterSpacing: -0.2,
                        //           shadows: [
                        //             Shadow(
                        //               color: Colors.black.withOpacity(0.3),
                        //               offset: const Offset(0, 1),
                        //               blurRadius: 4,
                        //             ),
                        //           ],
                        //         ),
                        //     maxLines: 1,
                        //     overflow: TextOverflow.ellipsis,
                        //   ),
                        // ),
                        // Info
                        Row(
                          children: [
                            _buildTinderTag(
                              icon: Iconsax.heart,
                              label: 'Here for ${widget.profile.intent}',
                            ),
                            const SizedBox(width: 10), // spacing between tags
                          ],
                        ),

                        // Interests
                        if (widget.profile.interests.isNotEmpty) ...[
                          SizedBox(height: 8.w),
                          Wrap(
                            spacing: 4.w,
                            runSpacing: 4,
                            children: widget.profile.interests
                                .take(4)
                                .map(
                                  (interest) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.25),
                                          Colors.white.withOpacity(0.15),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 0.7.w,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      interest,
                                      style:
                                          appStyle(
                                            13,
                                            Colors.white,
                                            FontWeight.w700,
                                          ).copyWith(
                                            letterSpacing: 0.2,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                offset: const Offset(0, 1),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        SizedBox(height: 50.h),

                        // Quick actions or extra info badge (optional)
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
}

Widget _buildTinderTag({required IconData icon, required String label}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.12),
          Colors.white.withOpacity(0.06),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.20), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: appStyle(15, Colors.white, FontWeight.w600).copyWith(
            letterSpacing: -0.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.35),
                offset: const Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}
