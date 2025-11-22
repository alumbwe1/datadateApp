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
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for the loading indicator
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Scale animation for the logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _scaleController.forward();

    _checkAuthStatus();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Check if user is logged in with timeout
      await ref
          .read(authProvider.notifier)
          .checkAuthStatus()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏱️ Auth check timed out - redirecting to login');
            },
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.user != null) {
        context.go('/encounters');
      } else {
        if (mounted) {
          debugPrint('🔓 No user found - redirecting to login');
          context.go('/login');
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
      backgroundColor: Color(0xFF1565C0),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF1565C0)),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo and Title Section
              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/dataDate.png',
                        height: 80,
                        width: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'DataDate',
                      style: appStyle(42, Colors.white, FontWeight.w900)
                          .copyWith(
                            letterSpacing: -1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Custom Loading Indicator
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(50, 50),
                      painter: CircularLoadingPainter(
                        progress: _rotationController.value,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the loading indicator
class CircularLoadingPainter extends CustomPainter {
  final double progress;

  CircularLoadingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Animated arc
    final arcPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    const sweepAngle = math.pi * 1.5; // 270 degrees

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(CircularLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
