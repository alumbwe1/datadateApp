import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class OnboardingWelcomePage extends ConsumerStatefulWidget {
  const OnboardingWelcomePage({super.key});

  @override
  ConsumerState<OnboardingWelcomePage> createState() =>
      _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends ConsumerState<OnboardingWelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late AnimationController _gridController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late AnimationController _matchAnimationController;
  late Animation<double> _matchScaleAnimation;
  late Animation<double> _matchProgressAnimation;

  @override
  void initState() {
    super.initState();
    _matchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _matchScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _matchAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _matchProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _matchAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _matchAnimationController.forward();
      }
    });

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _gridController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    _gridController.dispose();
    _glowController.dispose();
    _matchAnimationController.dispose();
    super.dispose();
  }

  int _calculateMatchPercentage() {
    // Calculate match percentage based on profile data
    return 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A14),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F1E),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced particles background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _particleController,
                  _glowController,
                ]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: EnhancedParticlePainter(
                      animation: _particleController.value,
                      glowAnimation: _glowController.value,
                    ),
                  );
                },
              ),
            ),

            // Gradient overlay for depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),

                        // Enhanced Logo with animation
                        Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                width: 60.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accentLight,
                                      const Color(0xFFFF6B9D),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentLight.withValues(
                                        alpha:
                                            0.6 *
                                            (0.7 + _glowController.value * 0.3),
                                      ),
                                      blurRadius:
                                          30 + (_glowController.value * 10),
                                      spreadRadius:
                                          5 + (_glowController.value * 5),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFF6B9D).withValues(
                                        alpha:
                                            0.4 *
                                            (0.6 + _glowController.value * 0.4),
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/heartlink.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.favorite_rounded,
                                              size: 35.sp,
                                              color: AppColors.accentLight,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Enhanced Profile Grid
                        _buildEnhancedProfileGrid(),

                        SizedBox(height: 30.h),

                        // App Logo with animated gradient
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accentLight,
                                  const Color(0xFFFF6B9D),
                                  AppColors.accentLight.withValues(alpha: 0.9),
                                ],
                                stops: [
                                  0.0,
                                  0.5 + _glowController.value * 0.3,
                                  1.0,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'HeartLink',
                                style: appStyle(
                                  52,
                                  Colors.white,
                                  FontWeight.w900,
                                ).copyWith(letterSpacing: -2.5, height: 1.0),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 10.h),

                        // Tagline with subtle animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                'Find Your Perfect Match',
                                style: appStyle(
                                  24,
                                  Colors.white,
                                  FontWeight.w700,
                                ).copyWith(letterSpacing: -0.5),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  'Join thousands discovering meaningful\nconnections every day',
                                  style: appStyle(
                                    13.sp,
                                    Colors.white.withValues(alpha: 0.65),
                                    FontWeight.w400,
                                  ).copyWith(height: 1.6),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Enhanced Get Started Button
                        _buildEnhancedButton(
                          text: 'Get Started',
                          onPressed: () => context.push('/login'),
                          isPrimary: true,
                        ),

                        SizedBox(height: 10.h),

                        // Sign up prompt with better styling
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: appStyle(
                                14,
                                Colors.white.withValues(alpha: 0.6),
                                FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/login'),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: appStyle(
                                    14,
                                    AppColors.accentLight,
                                    FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedProfileGrid() {
    return AnimatedBuilder(
      animation: _gridController,
      builder: (context, child) {
        return SizedBox(
          height: 360.h,
          child: Stack(
            children: [
              // Multi-layer animated glow
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentLight.withValues(
                              alpha: 0.2 * (0.4 + _glowController.value * 0.6),
                            ),
                            const Color(0xFFFF6B9D).withValues(
                              alpha: 0.15 * (0.3 + _glowController.value * 0.7),
                            ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: ScreenUtil().screenHeight * 0.4,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main big image (center)
                      Positioned(
                        left: 10.w,
                        top: 110.h,
                        child: _gridImage('assets/images/guy.jpeg'),
                      ),
                      Positioned(
                        top: 260.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _matchScaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _matchScaleAnimation.value,
                                child: child,
                              );
                            },
                            child: _buildCircularMatchIndicator(),
                          ),
                        ),
                      ),

                      // Top-right small image
                      Positioned(
                        right: 5.w,
                        top: 10.h,
                        child: _gridImage(
                          'assets/images/profile2.jpeg',

                          small: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircularMatchIndicator() {
    final matchPercentage = _calculateMatchPercentage();

    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated circular progress indicator
              AnimatedBuilder(
                animation: _matchProgressAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: CustomPaint(
                      painter: CircularProgressPainter(
                        progress:
                            (matchPercentage / 100) *
                            _matchProgressAnimation.value,
                        strokeWidth: 5,
                        color: Colors.deepPurpleAccent,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  );
                },
              ),
              // Animated percentage text
              AnimatedBuilder(
                animation: _matchProgressAnimation,
                builder: (context, child) {
                  final displayPercentage =
                      (matchPercentage * _matchProgressAnimation.value).toInt();
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          '$displayPercentage%',
                          style: appStyle(
                            15.sp,
                            Colors.black,
                            FontWeight.w900,
                          ).copyWith(letterSpacing: -0.5),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Match',
                style: appStyle(
                  17,
                  Colors.black,
                  FontWeight.w800,
                ).copyWith(letterSpacing: -0.4, height: 1),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurpleAccent.withValues(alpha: 0.2),
                      Colors.pinkAccent.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Great!',
                  style: appStyle(
                    10,
                    Colors.deepPurple,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gridImage(String asset, {bool small = false}) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(25.r),
      child: Image.asset(
        asset,
        width: ScreenUtil().screenWidth * 0.45,
        height: ScreenUtil().screenHeight * 0.3,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildEnhancedButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 58.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(29.r),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.accentLight.withValues(
                          alpha: 0.5 * (0.6 + _glowController.value * 0.4),
                        ),
                        blurRadius: 28,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withValues(
                          alpha: 0.3 * (0.5 + _glowController.value * 0.5),
                        ),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(29.r),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: isPrimary
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentLight,
                            const Color(0xFFFF6B9D),
                            AppColors.accentLight.withValues(alpha: 0.9),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(29.r),
                  border: Border.all(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: appStyle(
                      17,
                      Colors.white,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EnhancedParticlePainter extends CustomPainter {
  final double animation;
  final double glowAnimation;

  EnhancedParticlePainter({
    required this.animation,
    required this.glowAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Floating hearts with varied motion
    for (int i = 0; i < 15; i++) {
      final progress = (animation + (i / 15)) % 1.0;
      final drift = math.sin(progress * math.pi * 2) * 30;
      final x = (size.width * (i % 5) / 5) + (size.width * 0.1) + drift;
      final y = size.height - (progress * size.height * 1.3);
      final heartSize = 5.0 + (i % 4) * 2.5;
      final opacity = math.sin(progress * math.pi) * 0.3;

      paint.color = Color.lerp(
        const Color(0xFFE91E63),
        const Color(0xFFFF6B9D),
        (i % 12) / 12,
      )!.withValues(alpha: opacity);

      _drawHeart(canvas, Offset(x, y), heartSize, paint);
    }

    // Spiral particles
    for (int i = 0; i < 30; i++) {
      final progress = (animation * 0.4 + (i / 30)) % 1.0;
      final angle = (i / 30) * math.pi * 4 + (progress * math.pi * 2);
      final radius = progress * size.width * 0.5;
      final x = (size.width / 2) + (math.cos(angle) * radius);
      final y = (size.height / 2) + (math.sin(angle) * radius);
      final particleSize = (1 - progress) * (2.0 + (i % 3) * 0.5);
      final opacity = (1 - progress) * 0.35;

      paint.color = Color.lerp(
        const Color(0xFFFF4081),
        const Color(0xFFFF6B9D),
        glowAnimation,
      )!.withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }

    // Ambient glow particles
    for (int i = 0; i < 20; i++) {
      final progress = (animation * 0.6 + (i / 20)) % 1.0;
      final x = (size.width * (i % 4) / 4) + (size.width * 0.15);
      final y = (size.height * (i / 5) / 4) + (progress * 50);
      final glowSize = 3.0 + math.sin(progress * math.pi) * 2.0;
      final opacity = math.sin(progress * math.pi) * 0.2;

      paint.color = Colors.white.withValues(alpha: opacity);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), glowSize, paint);
      paint.maskFilter = null;
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.6,
      center.dy - size * 0.2,
      center.dx - size * 0.6,
      center.dy - size * 0.8,
      center.dx,
      center.dy - size * 0.4,
    );
    path.cubicTo(
      center.dx + size * 0.6,
      center.dy - size * 0.8,
      center.dx + size * 0.6,
      center.dy - size * 0.2,
      center.dx,
      center.dy + size * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EnhancedParticlePainter oldDelegate) => true;
}

class EnhancedGridLinesPainter extends CustomPainter {
  final double progress;
  final Color color;

  EnhancedGridLinesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw lines with gradient effect
    final lines = [
      [centerX, centerY, centerX, 36.0], // top
      [centerX, centerY, size.width - 36, centerY], // right
      [centerX, centerY, centerX, size.height - 36], // bottom
      [centerX, centerY, 36.0, centerY], // left
    ];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.05),
          color.withValues(alpha: 0.2 * (0.6 + progress * 0.4)),
          color.withValues(alpha: 0.05),
        ],
      );

      paint.shader = gradient.createShader(
        Rect.fromPoints(Offset(line[0], line[1]), Offset(line[2], line[3])),
      );

      canvas.drawLine(
        Offset(line[0], line[1]),
        Offset(line[2], line[3]),
        paint,
      );
    }

    // Add glowing dots at connection points
    paint.shader = null;
    paint.style = PaintingStyle.fill;
    paint.color = color.withValues(alpha: 0.3 * (0.5 + progress * 0.5));
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (var line in lines) {
      canvas.drawCircle(Offset(line[2], line[3]), 3, paint);
    }
  }

  @override
  bool shouldRepaint(EnhancedGridLinesPainter oldDelegate) => true;
}

// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
