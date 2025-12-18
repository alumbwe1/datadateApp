import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class ChatErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ChatErrorState({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.red[900]!.withValues(alpha: 0.3)
                    : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Oops!',
              style: appStyle(
                26,
                isDarkMode ? Colors.white : Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: appStyle(
                15,
                isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                FontWeight.w500,
              ).copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.secondaryLight,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(
                    color: AppColors.secondaryLight,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: appStyle(
                      15,
                      AppColors.secondaryLight,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
