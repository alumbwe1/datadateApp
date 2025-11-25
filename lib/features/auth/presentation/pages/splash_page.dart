import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../providers/auth_provider.dart';
import 'dart:math' as math;

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Logo entrance animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _logoController.forward();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(minutes: 2));

    if (!mounted) return;

    try {
      await ref
          .read(authProvider.notifier)
          .checkAuthStatus()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏱️ Auth check timed out');
            },
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.user != null) {
        context.go('/encounters');
      } else {
        if (mounted) {
          context.go('/onboarding/welcome');
        }
      }
    } catch (e) {
      debugPrint('❌ Auth check failed: $e');
      if (mounted) {
        context.go('/login');
      }
    }
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
                    painter: SplashParticlePainter(
                      animation: _particleController.value,
                    ),
                  );
                },
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo with glow effect
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                final pulseValue =
                                    0.85 + (_pulseController.value * 0.15);
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer glow
                                    Container(
                                      width: 200 * pulseValue,
                                      height: 200 * pulseValue,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(
                                              0xFFE91E63,
                                            ).withValues(alpha: 0.4),
                                            const Color(
                                              0xFFE91E63,
                                            ).withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Middle glow
                                    Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            const Color(
                                              0xFFFF4081,
                                            ).withValues(alpha: 0.3),
                                            const Color(
                                              0xFFFF4081,
                                            ).withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Logo container
                                    Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFE91E63),
                                            Color(0xFFFF4081),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFE91E63,
                                            ).withValues(alpha: 0.5),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.favorite_rounded,
                                        size: 60.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // App name with gradient
                    FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFE91E63)],
                            ).createShader(bounds),
                            child: Text(
                              'HeartLink',
                              style: appStyle(
                                52,
                                Colors.white,
                                FontWeight.w900,
                              ).copyWith(letterSpacing: -2.0, height: 1.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Find Your Perfect Match',
                            style: appStyle(
                              15,
                              Colors.white.withValues(alpha: 0.6),
                              FontWeight.w400,
                            ).copyWith(letterSpacing: 1.2),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Modern loading indicator
                    FadeTransition(
                      opacity: _textOpacity,
                      child: AnimatedBuilder(
                        animation: _particleController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(60, 60),
                            painter: ModernLoadingPainter(
                              progress: _particleController.value,
                              color: const Color(0xFFE91E63),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Company branding
                    FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'powered by',
                            style: appStyle(
                              11,
                              Colors.white.withValues(alpha: 0.3),
                              FontWeight.w400,
                            ).copyWith(letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFFE91E63,
                                      ).withValues(alpha: 0.2),
                                      const Color(
                                        0xFFFF4081,
                                      ).withValues(alpha: 0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.bolt_rounded,
                                  size: 16,
                                  color: const Color(0xFFE91E63),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFE91E63),
                                        Color(0xFFFF4081),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  'Alumbwe Technologies',
                                  style: appStyle(
                                    16,
                                    Colors.white,
                                    FontWeight.w700,
                                  ).copyWith(letterSpacing: -0.3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashParticlePainter extends CustomPainter {
  final double animation;

  SplashParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Pink particles
    for (int i = 0; i < 40; i++) {
      final progress = (animation + (i / 40)) % 1.0;
      final angle = (i / 40) * math.pi * 2;
      final radius = progress * size.width * 0.6;

      final x = (size.width / 2) + (math.cos(angle) * radius);
      final y = (size.height / 2) + (math.sin(angle) * radius);

      final particleSize = (1 - progress) * (3 + (i % 3));
      final opacity = (1 - progress) * 0.6;

      paint.color = Color.lerp(
        const Color(0xFFE91E63),
        const Color(0xFFFF4081),
        (i % 10) / 10,
      )!.withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }

    // Heart particles
    for (int i = 0; i < 8; i++) {
      final progress = (animation * 0.5 + (i / 8)) % 1.0;
      final spreadAngle = (i / 8) * math.pi * 2;
      final distance = progress * size.height * 0.4;

      final x = (size.width / 2) + (math.cos(spreadAngle) * distance);
      final y = (size.height / 2) + (math.sin(spreadAngle) * distance);

      final heartSize = (1 - progress) * 8;
      final opacity = (1 - progress) * 0.4;

      paint.color = const Color(0xFFFF4081).withValues(alpha: opacity);

      _drawHeart(canvas, Offset(x, y), heartSize, paint);
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
  bool shouldRepaint(SplashParticlePainter oldDelegate) => true;
}

class ModernLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  ModernLoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Rotating arc
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final startAngle = progress * math.pi * 2;
    const sweepAngle = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Animated dots
    for (int i = 0; i < 3; i++) {
      final dotProgress = (progress + (i * 0.15)) % 1.0;
      final angle = dotProgress * math.pi * 2;
      final dotRadius = radius - 4;

      final x = center.dx + dotRadius * math.cos(angle);
      final y = center.dy + dotRadius * math.sin(angle);

      final dotPaint = Paint()
        ..color = color.withValues(alpha: 1.0 - (i * 0.2))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3.0 - (i * 0.5), dotPaint);
    }
  }

  @override
  bool shouldRepaint(ModernLoadingPainter oldDelegate) => true;
}
