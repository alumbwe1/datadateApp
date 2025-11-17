import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_style.dart';

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);
    final gradient = _getGradient(type);

    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle animated background pattern
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CustomPaint(
                    painter: _PatternPainter(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    // Animated icon with pulse effect
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(icon, color: Colors.white, size: 22),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 14.w),
                    // Text content with fade-in animation
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(20 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getTitle(type),
                              style: appStyle(13, Colors.white, FontWeight.w700)
                                  .copyWith(
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: const Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              message,
                              style: appStyle(
                                14,
                                Colors.white.withOpacity(0.95),
                                FontWeight.w500,
                              ).copyWith(height: 1.4, letterSpacing: 0.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Action button if provided
                    if (actionLabel != null && onAction != null) ...[
                      SizedBox(width: 8.w),
                      TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          actionLabel,
                          style: appStyle(13, Colors.white, FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Progress indicator
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: duration,
                  curve: Curves.linear,
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.r),
                        bottomRight: Radius.circular(16.r),
                      ),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.3),
                        ),
                        minHeight: 3,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.zero,
        duration: duration,
      ),
    );
  }

  static String _getTitle(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return 'SUCCESS';
      case SnackbarType.error:
        return 'ERROR';
      case SnackbarType.warning:
        return 'WARNING';
      case SnackbarType.info:
        return 'INFO';
    }
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF10B981);
      case SnackbarType.error:
        return const Color(0xFFEF4444);
      case SnackbarType.warning:
        return const Color(0xFFF59E0B);
      case SnackbarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  static LinearGradient _getGradient(SnackbarType type) {
    final color = _getColor(type);
    return LinearGradient(
      colors: [color, Color.lerp(color, Colors.black, 0.2)!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_rounded;
      case SnackbarType.error:
        return Icons.error_rounded;
      case SnackbarType.warning:
        return Icons.warning_rounded;
      case SnackbarType.info:
        return Icons.info_rounded;
    }
  }
}

// Custom painter for subtle background pattern
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum SnackbarType { success, error, warning, info }
