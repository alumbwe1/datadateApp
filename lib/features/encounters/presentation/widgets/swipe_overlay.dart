import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';

class SwipeOverlay extends StatefulWidget {
  final bool isLike;
  final double opacity;

  const SwipeOverlay({super.key, required this.isLike, required this.opacity});

  @override
  State<SwipeOverlay> createState() => _SwipeOverlayState();
}

class _SwipeOverlayState extends State<SwipeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: widget.opacity,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isLike
                  ? [
                      Colors.green.withValues(alpha: 0.4),
                      Colors.green.withValues(alpha: 0.1),
                    ]
                  : [
                      Colors.red.withValues(alpha: 0.4),
                      Colors.red.withValues(alpha: 0.1),
                    ],
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle:
                        (widget.isLike ? -0.3 : 0.3) * _rotationAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: widget.isLike ? Colors.green : Colors.red,
                      width: 5,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.isLike ? Colors.green : Colors.red)
                            .withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isLike ? Icons.favorite : Icons.close,
                        color: widget.isLike ? Colors.green : Colors.red,
                        size: 48.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        widget.isLike ? 'LIKE' : 'NOPE',
                        style:
                            appStyle(
                              52.sp,
                              widget.isLike ? Colors.green : Colors.red,
                              FontWeight.w900,
                            ).copyWith(
                              letterSpacing: 6,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
