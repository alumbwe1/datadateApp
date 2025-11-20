import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/onboarding_progress.dart';
import '../providers/onboarding_provider.dart';

class OnboardingIntentPage extends ConsumerWidget {
  const OnboardingIntentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIntent = ref.watch(onboardingProvider).intent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnboardingProgress(currentStep: 4, totalSteps: 10),
                    SizedBox(height: 20.h),
                    Text(
                      'What are you\nlooking for?',
                      style: appStyle(
                        32,
                        Colors.black,
                        FontWeight.w900,
                      ).copyWith(letterSpacing: -0.5, height: 1.2),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Be honest about your intentions',
                      style: appStyle(
                        15,
                        Colors.grey[600]!,
                        FontWeight.w400,
                      ).copyWith(letterSpacing: -0.2, height: 1.4),
                    ),
                    SizedBox(height: 40.h),

                    _IntentOption(
                      emoji: '❤️',
                      title: 'Relationship',
                      description: 'Looking for something serious',
                      value: 'relationship',
                      isSelected: selectedIntent == 'relationship',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(onboardingProvider.notifier)
                            .setIntent('relationship');
                      },
                    ),

                    SizedBox(height: 16.h),

                    _IntentOption(
                      emoji: '☕',
                      title: 'Dating',
                      description: 'Open to casual dating',
                      value: 'dating',
                      isSelected: selectedIntent == 'dating',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(onboardingProvider.notifier)
                            .setIntent('dating');
                      },
                    ),

                    SizedBox(height: 16.h),

                    _IntentOption(
                      emoji: '🤝',
                      title: 'Friends',
                      description: 'Just looking to make friends',
                      value: 'friends',
                      isSelected: selectedIntent == 'friends',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(onboardingProvider.notifier)
                            .setIntent('friends');
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomButton(
                text: 'Continue',
                onPressed: selectedIntent != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.push('/onboarding/profile/bio');
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntentOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntentOption({
    required this.emoji,
    required this.title,
    required this.description,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(emoji, style: TextStyle(fontSize: 28.sp)),
              ),
            ),

            SizedBox(width: 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: appStyle(
                      16,
                      isSelected ? Colors.white : Colors.black,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: -0.2),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: appStyle(
                      13,
                      isSelected ? Colors.white70 : Colors.grey[600]!,
                      FontWeight.w400,
                    ).copyWith(letterSpacing: -0.1),
                  ),
                ],
              ),
            ),

            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16.sp, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
