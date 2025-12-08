import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import 'welcome_painters.dart';

class WelcomeMatchIndicator extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> progressAnimation;
  final int matchPercentage;

  const WelcomeMatchIndicator({
    super.key,
    required this.scaleAnimation,
    required this.progressAnimation,
    required this.matchPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: scaleAnimation.value, child: child);
      },
      child: Container(
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
                  animation: progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: CustomPaint(
                        painter: CircularProgressPainter(
                          progress:
                              (matchPercentage / 100) * progressAnimation.value,
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
                  animation: progressAnimation,
                  builder: (context, child) {
                    final displayPercentage =
                        (matchPercentage * progressAnimation.value).toInt();
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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
      ),
    );
  }
}
