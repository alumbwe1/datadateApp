import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Custom painter for enhanced particle effects with hearts and spirals
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

/// Custom painter for circular progress indicator
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
