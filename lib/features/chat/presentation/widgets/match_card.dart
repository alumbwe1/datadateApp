import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
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
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Create staggered entrance animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.1,
          0.4 + (widget.index * 0.1),
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.match.otherUser;
    final profile = otherUser?.profile;
    final imageUrls = profile?.imageUrls ?? [];
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    final displayName = otherUser?.displayName ?? 'Unknown';
    final firstName = displayName.split(' ').first;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.92 : 1.0,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              HapticFeedback.mediumImpact();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              Future.delayed(const Duration(milliseconds: 100), () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ChatDetailPage(roomId: widget.match.id),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          var tween = Tween(
                            begin: 0.0,
                            end: 1.0,
                          ).chain(CurveTween(curve: Curves.easeOutCubic));
                          return FadeTransition(
                            opacity: animation.drive(tween),
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                );
              });
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: Container(
              width: 115.w,
              margin: EdgeInsets.only(right: 14.w, bottom: 8.h),
              child: Column(
                children: [
                  // Main Card Container
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Animated glow effect
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 115.w,
                        height: 115.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withOpacity(
                                _glowAnimation.value * 0.4,
                              ),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),

                      // Main Image Container
                      Hero(
                        tag: 'match_${widget.match.id}',
                        child: Container(
                          width: 115.w,
                          height: 115.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28.r),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryLight.withOpacity(0.15),
                                AppColors.secondaryLight.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28.r),
                                child: imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        placeholder: (context, url) =>
                                            _buildShimmerPlaceholder(),
                                        errorWidget: (context, url, error) =>
                                            _buildAvatarPlaceholder(
                                              displayName,
                                            ),
                                      )
                                    : _buildAvatarPlaceholder(displayName),
                              ),

                              // Gradient Overlay for depth
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28.r),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.15),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),

                              // Glossy shine effect
                              Positioned(
                                top: 8.h,
                                left: 8.w,
                                right: 8.w,
                                child: Container(
                                  height: 35.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Animated Heart Badge
                      Positioned(
                        top: -6.h,
                        right: -6.w,
                        child: Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: EdgeInsets.all(9.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryLight,
                                  AppColors.secondaryLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryLight.withOpacity(
                                    0.5,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Iconsax.heart,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // New Match Badge (optional - for recent matches)
                      if (widget.index < 3)
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.orange.shade500,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 10.sp,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Name with typing indicator animation
                  Column(
                    children: [
                      Text(
                        firstName,
                        style: appStyle(
                          15.sp,
                          Colors.black87,
                          FontWeight.w800,
                        ).copyWith(letterSpacing: -0.3, height: 1.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),

                      // Typing indicator or unread count
                      SizedBox(height: 4.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.3),
            AppColors.secondaryLight.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: appStyle(32.sp, Colors.white, FontWeight.w800),
        ),
      ),
    );
  }
}
