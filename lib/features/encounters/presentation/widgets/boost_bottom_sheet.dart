import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class BoostBottomSheet extends ConsumerStatefulWidget {
  const BoostBottomSheet({super.key});

  @override
  ConsumerState<BoostBottomSheet> createState() => _BoostBottomSheetState();
}

class _BoostBottomSheetState extends ConsumerState<BoostBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _slideController;
  late Animation<double> _glowAnimation;
  late Animation<double> _slideAnimation;

  String _selectedPlan = 'Go';
  double _amount = 10.0;

  final List<Map<String, dynamic>> _boostPackages = [
    {
      'name': 'Go',
      'duration': 1,
      'views': '50+',
      'amount': 5.0,
      'popular': false,
      'color': const Color(0xFF00D4FF),
      'description': 'Perfect starter',
    },
    {
      'name': 'Pro',
      'duration': 3,
      'views': '150+',
      'amount': 10.0,
      'popular': true,
      'color': const Color(0xFFFF6B9D),
      'description': 'Most popular',
    },
    {
      'name': 'Plus',
      'duration': 7,
      'views': '500+',
      'amount': 25.0,
      'popular': false,
      'color': const Color(0xFFFFD700),
      'description': 'Maximum visibility',
    },
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF1A1A2E),
            AppColors.accentLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(17.r)),
      ),
      child: Stack(
        children: [
          // Animated particles background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    animation: _particleController.value,
                    color: AppColors.accentLight,
                  ),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: FadeTransition(
                opacity: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
                        width: 36.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Glowing Boost Icon
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow
                              Container(
                                width: 120.w * _glowAnimation.value,
                                height: 120.h * _glowAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.accentLight.withValues(
                                        alpha: 0.4,
                                      ),
                                      AppColors.accentLight.withValues(
                                        alpha: 0.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Main icon
                              Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accentLight,
                                      AppColors.accentLight.withValues(
                                        alpha: 0.7,
                                      ),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentLight.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  'assets/svgs/star2.svg',
                                  fit: BoxFit.none,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.accentLight,
                            AppColors.accentLight.withValues(alpha: 0.8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Get More Matches',
                          style: appStyle(
                            32,
                            Colors.white,
                            FontWeight.w900,
                          ).copyWith(letterSpacing: -1.0, height: 1.0),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Text(
                          'Boost your profile to the top and get\n10x more visibility',
                          style: appStyle(
                            14,
                            Colors.white.withValues(alpha: 0.6),
                            FontWeight.w400,
                          ).copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Boost Packages
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: _boostPackages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final package = entry.value;
                            final isSelected = package['name'] == _selectedPlan;
                            final isPopular = package['popular'] as bool;
                            final planColor = package['color'] as Color;

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 400 + (index * 100),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _selectedPlan = package['name'] as String;
                                    _amount = package['amount'] as double;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  padding: EdgeInsets.all(18.w),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              planColor.withValues(alpha: 0.2),
                                              planColor.withValues(alpha: 0.05),
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? planColor.withValues(alpha: 0.6)
                                          : Colors.white.withValues(alpha: 0.1),
                                      width: isSelected ? 2.w : 1.w,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: planColor.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 20,
                                              spreadRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      // Plan Badge
                                      Container(
                                        width: 60.w,
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              planColor,
                                              planColor.withValues(alpha: 0.7),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: planColor.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            package['name'],
                                            style: appStyle(
                                              16,
                                              Colors.white,
                                              FontWeight.w900,
                                            ).copyWith(letterSpacing: 0.5),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 14.w),

                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    '${package['duration']} Days Boost',
                                                    style:
                                                        appStyle(
                                                          16,
                                                          Colors.white,
                                                          FontWeight.w700,
                                                        ).copyWith(
                                                          letterSpacing: -0.3,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isPopular) ...[
                                                  SizedBox(width: 6.w),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8.w,
                                                          vertical: 3.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                            colors: [
                                                              Color(0xFFFFD700),
                                                              Color(0xFFFFA500),
                                                            ],
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6.r,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '🔥',
                                                      style: appStyle(
                                                        10,
                                                        Colors.black,
                                                        FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              '${package['views']} views • ${package['description']}',
                                              style: appStyle(
                                                12,
                                                Colors.white.withValues(
                                                  alpha: 0.5,
                                                ),
                                                FontWeight.w400,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(width: 8.w),

                                      // Price
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'K',
                                                style: appStyle(
                                                  14,
                                                  isSelected
                                                      ? planColor
                                                      : Colors.white,
                                                  FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                package['amount']
                                                    .toStringAsFixed(0),
                                                style: appStyle(
                                                  22,
                                                  isSelected
                                                      ? planColor
                                                      : Colors.white,
                                                  FontWeight.w900,
                                                ).copyWith(letterSpacing: -0.5),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      SizedBox(width: 8.w),

                                      // Selection indicator
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: 22.w,
                                        height: 22.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    planColor,
                                                    planColor.withValues(
                                                      alpha: 0.8,
                                                    ),
                                                  ],
                                                )
                                              : null,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.transparent
                                                : Colors.white.withValues(
                                                    alpha: 0.2,
                                                  ),
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 14.sp,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Boost Button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentLight.withValues(
                                      alpha: 0.4 * _glowAnimation.value,
                                    ),
                                    blurRadius: 30 * _glowAnimation.value,
                                    spreadRadius: 5 * _glowAnimation.value,
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    _handleBoost();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28.r),
                                    ),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.accentLight,
                                          AppColors.accentLight.withValues(
                                            alpha: 0.8,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(28.r),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.bolt_rounded,
                                            color: Colors.white,
                                            size: 24.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Boost for K${_amount.toStringAsFixed(0)}',
                                            style: appStyle(
                                              17,
                                              Colors.white,
                                              FontWeight.w700,
                                            ).copyWith(letterSpacing: -0.3),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Terms
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Text(
                          'Your profile will appear first in discovery',
                          style: appStyle(
                            12,
                            Colors.white.withValues(alpha: 0.4),
                            FontWeight.w400,
                          ).copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible,
                        ),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBoost() async {
    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentLight,
                      AppColors.accentLight.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentLight.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_selectedPlan Boost Activated! 🚀',
                      style: appStyle(15, Colors.white, FontWeight.w700),
                    ),
                    Text(
                      'K${_amount.toStringAsFixed(0)} plan activated',
                      style: appStyle(13, Colors.white70, FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }
}

class ParticlePainter extends CustomPainter {
  final double animation;
  final Color color;

  ParticlePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final progress = (animation + (i / 30)) % 1.0;
      final x =
          (size.width * 0.5) +
          (math.cos(i * 0.5 + animation * math.pi * 2) *
              size.width *
              0.4 *
              progress);
      final y = size.height * 0.3 - (progress * size.height * 0.3);
      final radius = (1 - progress) * (3 + (i % 3));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
