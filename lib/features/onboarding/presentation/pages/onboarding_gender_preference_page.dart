import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/onboarding_progress.dart';
import '../providers/onboarding_provider.dart';

class OnboardingGenderPreferencePage extends ConsumerWidget {
  const OnboardingGenderPreferencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferredGenders = ref.watch(
      onboardingProvider.select((state) => state.preferredGenders),
    );

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingProgress(currentStep: 3, totalSteps: 10),
              SizedBox(height: 20.h),
              Text(
                'Who would you\nlike to date?',
                style: appStyle(
                  32,
                  Colors.black,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5, height: 1.2),
              ),
              SizedBox(height: 12.h),
              Text(
                'Select your dating preference.\nYou can change this later.',
                style: appStyle(
                  15,
                  Colors.grey[600]!,
                  FontWeight.w400,
                ).copyWith(letterSpacing: -0.2, height: 1.4),
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: Column(
                  children: [
                    _GenderPreferenceOption(
                      emoji: '👨',
                      title: 'Men',
                      description: 'Show me men',
                      isSelected:
                          preferredGenders.contains('male') &&
                          preferredGenders.length == 1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(onboardingProvider.notifier)
                            .setPreferredGenders(['male']);
                      },
                    ),
                    SizedBox(height: 16.h),
                    _GenderPreferenceOption(
                      emoji: '👩',
                      title: 'Women',
                      description: 'Show me women',
                      isSelected:
                          preferredGenders.contains('female') &&
                          preferredGenders.length == 1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(onboardingProvider.notifier)
                            .setPreferredGenders(['female']);
                      },
                    ),
                    SizedBox(height: 16.h),
                    _GenderPreferenceOption(
                      emoji: '🌈',
                      title: 'Everyone',
                      description: 'Show me everyone',
                      isSelected:
                          preferredGenders.length > 1 ||
                          preferredGenders.contains('other'),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(onboardingProvider.notifier)
                            .setPreferredGenders(['male', 'female', 'other']);
                      },
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: 'Continue',
                onPressed: preferredGenders.isNotEmpty
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.push('/onboarding/intent');
                      }
                    : null,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderPreferenceOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderPreferenceOption({
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
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
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
                      18,
                      isSelected ? Colors.white : Colors.black,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: -0.3),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: appStyle(
                      14,
                      isSelected ? Colors.white70 : Colors.grey[600]!,
                      FontWeight.w400,
                    ).copyWith(letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
