import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
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
  late AnimationController _matchController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _matchController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    _matchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E), Color(0xFF16213E)],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WelcomeParticlePainter(
                      animation: _particleController.value,
                    ),
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),

                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => context.go('/encounters'),
                          child: Text(
                            'Skip',
                            style: appStyle(
                              16,
                              Colors.white.withValues(alpha: 0.7),
                              FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // Profile matching visualization
                      _buildMatchingVisualization(),

                      SizedBox(height: 48.h),

                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFE91E63)],
                        ).createShader(bounds),
                        child: Text(
                          'find your',
                          style: appStyle(
                            32,
                            Colors.white,
                            FontWeight.w600,
                          ).copyWith(letterSpacing: -0.5, height: 1.2),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
                        ).createShader(bounds),
                        child: Text(
                          'perfect match',
                          style: appStyle(
                            48,
                            Colors.white,
                            FontWeight.w900,
                          ).copyWith(letterSpacing: -2.0, height: 0.9),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          'Connect with people who share your\ninterests and make meaningful connections',
                          style: appStyle(
                            15,
                            Colors.white.withValues(alpha: 0.6),
                            FontWeight.w400,
                          ).copyWith(height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Feature chips
                      _buildFeatureRow(),

                      const Spacer(flex: 2),

                      // Get Started Button
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFE91E63,
                                ).withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => context.push('/login'),
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
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE91E63),
                                    Color(0xFFFF4081),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28.r),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Get Started',
                                  style: appStyle(
                                    17,
                                    Colors.white,
                                    FontWeight.w700,
                                  ).copyWith(letterSpacing: -0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingVisualization() {
    return SizedBox(
      height: 280.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connection line with glow
          AnimatedBuilder(
            animation: _matchController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(300.w, 280.h),
                painter: ConnectionLinePainter(
                  progress: _matchController.value,
                ),
              );
            },
          ),

          // Left profile
          Positioned(
            left: 20.w,
            top: 60.h,
            child: _buildProfileCard(
              'assets/images/guy.jpg',
              'You',
              Colors.purple.shade300,
            ),
          ),

          // Right profile
          Positioned(
            right: 20.w,
            top: 60.h,
            child: _buildProfileCard(
              'assets/images/profile2.jpeg',
              'Match',
              Colors.pink.shade300,
            ),
          ),

          // Center match indicator
          Center(
            child: AnimatedBuilder(
              animation: _matchController,
              builder: (context, child) {
                final scale = 0.9 + (_matchController.value * 0.1);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 90.w,
                    height: 90.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFE91E63).withValues(alpha: 0.3),
                          const Color(0xFFE91E63).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFE91E63,
                            ).withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '100%',
                            style: appStyle(
                              20,
                              Colors.white,
                              FontWeight.w900,
                            ).copyWith(letterSpacing: -0.5, height: 1.0),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Match',
                            style: appStyle(
                              10,
                              Colors.white.withValues(alpha: 0.9),
                              FontWeight.w600,
                            ).copyWith(letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String imagePath, String label, Color accentColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.3),
                  accentColor.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person_rounded,
                    size: 50.sp,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              label,
              style: appStyle(12, Colors.white, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFeatureChip(Icons.verified_rounded, 'Verified'),
        SizedBox(width: 12.w),
        _buildFeatureChip(Icons.favorite_rounded, 'Safe'),
        SizedBox(width: 12.w),
        _buildFeatureChip(Icons.bolt_rounded, 'Fast'),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE91E63).withValues(alpha: 0.2),
              const Color(0xFFFF4081).withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFE91E63).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: const Color(0xFFFF4081)),
            SizedBox(width: 6.w),
            Text(
              label,
              style: appStyle(
                13,
                Colors.white.withValues(alpha: 0.9),
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeParticlePainter extends CustomPainter {
  final double animation;

  WelcomeParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Floating hearts
    for (int i = 0; i < 15; i++) {
      final progress = (animation + (i / 15)) % 1.0;
      final x = (size.width * (i % 3) / 3) + (size.width * 0.2);
      final y = size.height - (progress * size.height * 1.2);
      final heartSize = 8.0 + (i % 3) * 3.0;
      final opacity = (1 - progress) * 0.3;

      paint.color = Color.lerp(
        const Color(0xFFE91E63),
        const Color(0xFFFF4081),
        (i % 10) / 10,
      )!.withValues(alpha: opacity);

      _drawHeart(canvas, Offset(x, y), heartSize, paint);
    }

    // Circular particles
    for (int i = 0; i < 30; i++) {
      final progress = (animation * 0.5 + (i / 30)) % 1.0;
      final angle = (i / 30) * math.pi * 2;
      final radius = progress * size.width * 0.5;
      final x = (size.width / 2) + (math.cos(angle) * radius);
      final y = (size.height / 2) + (math.sin(angle) * radius);
      final particleSize = (1 - progress) * (2 + (i % 2));
      final opacity = (1 - progress) * 0.4;

      paint.color = const Color(0xFFFF4081).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
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
  bool shouldRepaint(WelcomeParticlePainter oldDelegate) => true;
}

class ConnectionLinePainter extends CustomPainter {
  final double progress;

  ConnectionLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Glowing connection line
    final startX = size.width * 0.25;
    final endX = size.width * 0.75;
    final y = size.height * 0.5;

    // Draw multiple lines for glow effect
    for (int i = 0; i < 3; i++) {
      paint
        ..color = const Color(0xFFE91E63).withValues(alpha: 0.2 - (i * 0.05))
        ..strokeWidth = 2.0 + (i * 2);

      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }

    // Animated pulse along the line
    final pulseX = startX + ((endX - startX) * progress);
    final pulsePaint = Paint()
      ..color = const Color(0xFFFF4081).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(pulseX, y), 4.0, pulsePaint);
  }

  @override
  bool shouldRepaint(ConnectionLinePainter oldDelegate) => true;
}
