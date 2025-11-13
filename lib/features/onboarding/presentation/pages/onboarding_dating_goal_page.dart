import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/onboarding_provider.dart';

class OnboardingDatingGoalPage extends ConsumerWidget {
  const OnboardingDatingGoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGoal = ref.watch(onboardingProvider).datingGoal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
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
                      'Be honest about what you want. You can\nchange this anytime.',
                      style: appStyle(
                        15,
                        Colors.grey[600]!,
                        FontWeight.w400,
                      ).copyWith(letterSpacing: -0.2, height: 1.4),
                    ),

                    SizedBox(height: 40.h),

                    _DatingGoalOption(
                      emoji: '☕',
                      title: 'Here to date',
                      description: 'I want to go on dates and have a good time',
                      isSelected: selectedGoal == 'date',
                      onTap: () => ref
                          .read(onboardingProvider.notifier)
                          .setDatingGoal('date'),
                    ),

                    SizedBox(height: 16.h),

                    _DatingGoalOption(
                      emoji: '💬',
                      title: 'Open to chat',
                      description: 'I\'m here to chat and see where it goes',
                      isSelected: selectedGoal == 'chat',
                      onTap: () => ref
                          .read(onboardingProvider.notifier)
                          .setDatingGoal('chat'),
                    ),

                    SizedBox(height: 16.h),

                    _DatingGoalOption(
                      emoji: '❤️',
                      title: 'Ready for a relationship',
                      description: 'I\'m looking for something that lasts',
                      isSelected: selectedGoal == 'relationship',
                      onTap: () => ref
                          .read(onboardingProvider.notifier)
                          .setDatingGoal('relationship'),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomButton(
                text: 'Continue',
                onPressed: selectedGoal != null
                    ? () => context.push('/onboarding/interests')
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatingGoalOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _DatingGoalOption({
    required this.emoji,
    required this.title,
    required this.description,
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
