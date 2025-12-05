import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_style.dart';
import '../pages/chat_detail_page.dart';

class MatchCard extends StatefulWidget {
  final dynamic match;
  final int index;

  const MatchCard({super.key, required this.match, required this.index});

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.match.otherUser;
    final profile = otherUser?.profile;
    final imageUrls = profile?.imageUrls ?? [];
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    final displayName = otherUser?.displayName ?? 'Unknown';
    final isNew = widget.index < 3;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          _scaleController.forward();
          HapticFeedback.mediumImpact();
        },
        onTapUp: (_) {
          _scaleController.reverse();
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChatDetailPage(roomId: widget.match.id),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 250),
              ),
            );
          });
        },
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          width: 114.w,
          margin: EdgeInsets.only(right: 14.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gradient border container for new matches
                  if (isNew)
                    Container(
                      width: 116.w,
                      height: 154.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF6B9D), // Pink
                            Color(0xFFFFC3A0), // Peach
                            Color(0xFFFF6B9D), // Pink
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF6B9D).withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),

                  // Main card container
                  Container(
                    width: 114.w,
                    height: 154.h,
                    margin: isNew ? EdgeInsets.all(2.w) : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isNew ? 12.r : 14.r),
                      boxShadow: !isNew
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isNew ? 12.r : 14.r),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Profile image
                          imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      _buildShimmerPlaceholder(),
                                  errorWidget: (context, url, error) =>
                                      _buildAvatarPlaceholder(displayName),
                                )
                              : _buildAvatarPlaceholder(displayName),

                          // Enhanced gradient overlay for better text visibility
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Name overlay with better styling
                          Positioned(
                            bottom: 10.h,
                            left: 10.w,
                            right: 10.w,
                            child: Text(
                              displayName,
                              style:
                                  appStyle(
                                    14.sp,
                                    Colors.white,
                                    FontWeight.w700,
                                  ).copyWith(
                                    letterSpacing: -0.3,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // "NEW" badge for new matches
                          if (isNew)
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B9D),
                                      Color(0xFFFF8FB3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFFF6B9D).withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'NEW',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    // Enhanced gradient colors
    final colors = [
      [Color(0xFFFF6B9D), Color(0xFFFFC3A0)], // Pink to Peach
      [Color(0xFF4ECDC4), Color(0xFF44A08D)], // Teal
      [Color(0xFF667EEA), Color(0xFF764BA2)], // Purple
      [Color(0xFFFF9A56), Color(0xFFFF6B9D)], // Orange to Pink
      [Color(0xFF56CCF2), Color(0xFF2F80ED)], // Blue
    ];

    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[index],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
