import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_style.dart';

class OnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    final percentage = (progress * 100).toInt();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8.h,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              '$percentage%',
              style: appStyle(14, Colors.black, FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: appStyle(12, Colors.grey[600]!, FontWeight.w500),
            ),
            Text(
              '${totalSteps - currentStep} steps left',
              style: appStyle(12, Colors.grey[600]!, FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
