import 'dart:math' as math;

import 'package:flutter/material.dart';

class NeonBorderContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final Color neonColor;
  final double glowIntensity;

  const NeonBorderContainer({
    super.key,
    required this.child,
    this.borderRadius = 30.0,
    this.borderWidth = 3.0,
    this.neonColor = const Color(0xFF00D9FF),
    this.glowIntensity = 20.0,
  });

  @override
  State<NeonBorderContainer> createState() => _NeonBorderContainerState();
}

class _NeonBorderContainerState extends State<NeonBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Space background
        Positioned.fill(child: CustomPaint(painter: SpaceBackgroundPainter())),

        // Animated neon border
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: NeonBorderPainter(
                  animation: _controller.value,
                  borderRadius: widget.borderRadius,
                  borderWidth: widget.borderWidth,
                  neonColor: widget.neonColor,
                  glowIntensity: widget.glowIntensity,
                ),
              );
            },
          ),
        ),

        // Content
        Padding(
          padding: EdgeInsets.all(widget.borderWidth + 10),
          child: widget.child,
        ),
      ],
    );
  }
}

class SpaceBackgroundPainter extends CustomPainter {
  final _random = math.Random(42); // Fixed seed for consistent stars

  @override
  void paint(Canvas canvas, Size size) {
    // Deep space gradient
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF000814),
        Color(0xFF001D3D),
        Color(0xFF003566),
        Color(0xFF001233),
      ],
      stops: [0.0, 0.3, 0.6, 1.0],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw stars
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 200; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final radius = _random.nextDouble() * 1.5 + 0.5;
      final opacity = _random.nextDouble() * 0.5 + 0.3;

      starPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Add some nebula-like glows
    final nebulaPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    nebulaPaint.color = const Color(0xFF6B4FBB).withValues(alpha: 0.15);
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.2),
      100,
      nebulaPaint,
    );

    nebulaPaint.color = const Color(0xFF00D9FF).withValues(alpha: 0.1);
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.8),
      120,
      nebulaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NeonBorderPainter extends CustomPainter {
  final double animation;
  final double borderRadius;
  final double borderWidth;
  final Color neonColor;
  final double glowIntensity;

  NeonBorderPainter({
    required this.animation,
    required this.borderRadius,
    required this.borderWidth,
    required this.neonColor,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Animated gradient offset
    final gradientOffset = animation * 2 * math.pi;

    // Create moving gradient
    final colors = [
      neonColor.withValues(alpha: 0.3),
      neonColor,
      neonColor.withValues(alpha: 1.0),
      neonColor,
      neonColor.withValues(alpha: 0.3),
    ];

    final stops = [
      0.0,
      (0.2 + animation * 0.3) % 1.0,
      (0.5 + animation * 0.3) % 1.0,
      (0.8 + animation * 0.3) % 1.0,
      1.0,
    ].map((s) => s.clamp(0.0, 1.0)).toList();

    // Outer glow layers for neon effect
    for (int i = 3; i > 0; i--) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth + (i * glowIntensity / 3)
        ..shader = SweepGradient(
          colors: colors,
          stops: stops,
          transform: GradientRotation(gradientOffset),
        ).createShader(rect.outerRect)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          glowIntensity * (i / 2),
        );

      canvas.drawRRect(rect, glowPaint);
    }

    // Main bright border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = SweepGradient(
        colors: colors,
        stops: stops,
        transform: GradientRotation(gradientOffset),
      ).createShader(rect.outerRect);

    canvas.drawRRect(rect, borderPaint);

    // Inner glow
    final innerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 0.5
      ..shader = SweepGradient(
        colors: colors.map((c) => c.withValues(alpha: c.a * 0.5)).toList(),
        stops: stops,
        transform: GradientRotation(gradientOffset),
      ).createShader(rect.outerRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawRRect(rect, innerGlowPaint);
  }

  @override
  bool shouldRepaint(NeonBorderPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
