import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_style.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie with error handling
            SizedBox(
              width: 170.w,
              height: 170.h,
              child: Lottie.asset(
                'assets/lottie/Chat.json',
                width: 170.w,
                height: 170.h,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if Lottie fails to load
                  debugPrint('❌ Lottie error: $error');
                  return Icon(
                    Icons.chat_bubble_outline,
                    size: 80.sp,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'No Messages Yet',
              style: appStyle(
                28.sp,
                isDark ? Colors.white : Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            Text(
              'Start swiping to match with people\nand begin conversations',
              style: appStyle(
                16.sp,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            ElevatedButton(
              onPressed: () {
                const NavigationNotification(0).dispatch(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Start Swiping',
                style: appStyle(
                  16,
                  isDark ? Colors.black : Colors.white,
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom notification for navigation
class NavigationNotification extends Notification {
  final int tabIndex;

  const NavigationNotification(this.tabIndex);
}