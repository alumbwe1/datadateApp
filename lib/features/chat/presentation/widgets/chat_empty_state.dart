import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryLight.withOpacity(0.1),
                    AppColors.secondaryLight.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryLight.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text('💬', style: TextStyle(fontSize: 64)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Messages Yet',
              style: appStyle(
                26,
                Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start swiping to match with people\nand begin conversations',
              style: appStyle(
                15,
                Colors.grey[600]!,
                FontWeight.w500,
              ).copyWith(height: 1.6, letterSpacing: -0.1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryLight,
                    AppColors.secondaryLight.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryLight.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Start Swiping',
                    style: appStyle(
                      15,
                      Colors.white,
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
