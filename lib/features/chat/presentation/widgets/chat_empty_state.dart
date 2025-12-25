import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_style.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5.h,
          children: [
            Lottie.asset(
              'assets/lottie/Chat.json',
              width: 170.h,
              height: 170.h,
              fit: BoxFit.contain,
            ),

            Text(
              'No Messages Yet',
              style: appStyle(
                28.sp,
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),

            Text(
              'Start swiping to match with people\nand begin conversations',
              style: appStyle(
                16.sp,
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]!
                    : Colors.grey[600]!,
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () {
                // Send a notification to switch to encounters tab
                const NavigationNotification(0).dispatch(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
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
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
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
