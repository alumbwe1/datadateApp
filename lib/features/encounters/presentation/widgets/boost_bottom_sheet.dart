import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
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

  int _selectedDuration = 2;
  double _amount = 10.0;

  final List<Map<String, dynamic>> _boostPackages = [
    {'duration': 1, 'views': 50, 'amount': 5.0, 'popular': false},
    {'duration': 2, 'views': 100, 'amount': 10.0, 'popular': true},
    {'duration': 4, 'views': 200, 'amount': 18.0, 'popular': false},
    {'duration': 8, 'views': 500, 'amount': 35.0, 'popular': false},
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
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
                                child: Icon(
                                  Icons.bolt_rounded,
                                  size: 42.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: 28.h),

                      // Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0.8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'boost your',
                          style: appStyle(
                            24,
                            Colors.white,
                            FontWeight.w500,
                          ).copyWith(letterSpacing: -0.5),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.accentLight,
                            const Color(0xFF6B8AFF),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'visibility',
                          style: appStyle(
                            42,
                            Colors.white,
                            FontWeight.w900,
                          ).copyWith(letterSpacing: -1.5, height: 1.0),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          'Get 10x more profile views and increase\nyour chances of matching',
                          style: appStyle(
                            14,
                            Colors.white.withValues(alpha: 0.6),
                            FontWeight.w400,
                          ).copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 36.h),

                      // Boost Packages
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: _boostPackages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final package = entry.value;
                            final isSelected =
                                package['duration'] == _selectedDuration;
                            final isPopular = package['popular'] as bool;

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
                                    _selectedDuration =
                                        package['duration'] as int;
                                    _amount = package['amount'] as double;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.accentLight.withValues(
                                                alpha: 0.25,
                                              ),
                                              AppColors.accentLight.withValues(
                                                alpha: 0.1,
                                              ),
                                            ],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accentLight.withValues(
                                              alpha: 0.6,
                                            )
                                          : Colors.white.withValues(alpha: 0.1),
                                      width: isSelected ? 2.w : 1.w,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.accentLight
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 20,
                                              spreadRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: 56.w,
                                        height: 56.h,
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    AppColors.accentLight,
                                                    AppColors.accentLight
                                                        .withValues(alpha: 0.7),
                                                  ],
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    Colors.white.withValues(
                                                      alpha: 0.1,
                                                    ),
                                                    Colors.white.withValues(
                                                      alpha: 0.05,
                                                    ),
                                                  ],
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.accentLight
                                                        .withValues(alpha: 0.4),
                                                    blurRadius: 12,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          Icons.bolt_rounded,
                                          color: Colors.white,
                                          size: 28.sp,
                                        ),
                                      ),

                                      SizedBox(width: 16.w),

                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '${package['duration']} Hour${package['duration'] > 1 ? 's' : ''}',
                                                  style:
                                                      appStyle(
                                                        18,
                                                        Colors.white,
                                                        FontWeight.w700,
                                                      ).copyWith(
                                                        letterSpacing: -0.5,
                                                      ),
                                                ),
                                                if (isPopular) ...[
                                                  SizedBox(width: 10.w),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 10.w,
                                                          vertical: 4.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          const Color(
                                                            0xFFFFD700,
                                                          ),
                                                          const Color(
                                                            0xFFFFA500,
                                                          ),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.r,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              const Color(
                                                                0xFFFFD700,
                                                              ).withValues(
                                                                alpha: 0.4,
                                                              ),
                                                          blurRadius: 8,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      'POPULAR',
                                                      style:
                                                          appStyle(
                                                            9,
                                                            Colors.black,
                                                            FontWeight.w900,
                                                          ).copyWith(
                                                            letterSpacing: 0.5,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              '~${package['views']} profile views',
                                              style: appStyle(
                                                13,
                                                Colors.white.withValues(
                                                  alpha: 0.5,
                                                ),
                                                FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Price
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'K${package['amount'].toStringAsFixed(0)}',
                                            style: appStyle(
                                              24,
                                              isSelected
                                                  ? AppColors.accentLight
                                                  : Colors.white,
                                              FontWeight.w800,
                                            ).copyWith(letterSpacing: -0.8),
                                          ),
                                          Text(
                                            'ZMW',
                                            style: appStyle(
                                              11,
                                              Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                              FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Selection indicator
                                      SizedBox(width: 12.w),
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: 24.w,
                                        height: 24.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    AppColors.accentLight,
                                                    AppColors.accentLight
                                                        .withValues(alpha: 0.8),
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
                                                size: 16.sp,
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

                      SizedBox(height: 32.h),

                      // Boost Button with Glow
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
                                          const Color(0xFF6B8AFF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(28.r),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.bolt_rounded,
                                            color: Colors.white,
                                            size: 24.sp,
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            'Boost for K${_amount.toStringAsFixed(0)}',
                                            style: appStyle(
                                              17,
                                              Colors.white,
                                              FontWeight.w700,
                                            ).copyWith(letterSpacing: -0.3),
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
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          'Your profile will be shown first in discovery for $_selectedDuration hour${_selectedDuration > 1 ? 's' : ''}',
                          style: appStyle(
                            12,
                            Colors.white.withValues(alpha: 0.4),
                            FontWeight.w400,
                          ).copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 32.h),
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
                      'Boost Activated! 🚀',
                      style: appStyle(15, Colors.white, FontWeight.w700),
                    ),
                    Text(
                      'K${_amount.toStringAsFixed(0)} for $_selectedDuration hour${_selectedDuration > 1 ? 's' : ''}',
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
