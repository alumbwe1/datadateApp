import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class LikesErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const LikesErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [
                          Colors.red[900]!.withValues(alpha: 0.3),
                          Colors.red[800]!.withValues(alpha: 0.2),
                        ]
                      : [
                          Colors.red[50]!,
                          Colors.red[100]!.withValues(alpha: 0.3),
                        ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 72,
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
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: appStyle(
                15,
                isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
                shadowColor: AppColors.secondaryLight.withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: appStyle(15, Colors.white, FontWeight.w700),
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
