import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/onboarding_progress.dart';
import '../providers/onboarding_provider.dart';

class OnboardingInterestsPage extends ConsumerWidget {
  const OnboardingInterestsPage({super.key});

  static const List<Map<String, String>> availableInterests = [
    {'name': 'Photography', 'emoji': '📷'},
    {'name': 'Music', 'emoji': '🎵'},
    {'name': 'Travel', 'emoji': '✈️'},
    {'name': 'Fitness', 'emoji': '💪'},
    {'name': 'Cooking', 'emoji': '🍳'},
    {'name': 'Art', 'emoji': '🎨'},
    {'name': 'Reading', 'emoji': '📚'},
    {'name': 'Gaming', 'emoji': '🎮'},
    {'name': 'Movies', 'emoji': '🎬'},
    {'name': 'Sports', 'emoji': '⚽'},
    {'name': 'Dancing', 'emoji': '🕺'},
    {'name': 'Technology', 'emoji': '💻'},
    {'name': 'Fashion', 'emoji': '👗'},
    {'name': 'Nature', 'emoji': '🌿'},
    {'name': 'Yoga', 'emoji': '🧘'},
    {'name': 'Coffee', 'emoji': '☕'},
    {'name': 'Pets', 'emoji': '🐶'},
    {'name': 'Wine', 'emoji': '🍷'},

    {'name': 'Cycling', 'emoji': '🚴'},
    {'name': 'Hiking', 'emoji': '🥾'},
    {'name': 'Swimming', 'emoji': '🏊'},
    {'name': 'Podcasts', 'emoji': '🎧'},
    {'name': 'Writing', 'emoji': '✍️'},
    {'name': 'Cars', 'emoji': '🚗'},
    {'name': 'Volunteering', 'emoji': '🤝'},
    {'name': 'Meditation', 'emoji': '🧠'},
    {'name': 'Karaoke', 'emoji': '🎤'},
    {'name': 'Baking', 'emoji': '🧁'},
    {'name': 'Shopping', 'emoji': '🛍️'},
    {'name': 'Board Games', 'emoji': '🎲'},
    {'name': 'Anime', 'emoji': '🉐'},
    {'name': 'Photography Editing', 'emoji': '🖼️'},
    {'name': 'Coding', 'emoji': '👨‍💻'},
    {'name': 'Entrepreneurship', 'emoji': '📈'},
    {'name': 'Skincare', 'emoji': '🧴'},
    {'name': 'Gardening', 'emoji': '🌱'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInterests = ref.watch(onboardingProvider).interests;

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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnboardingProgress(currentStep: 10, totalSteps: 10),
                  SizedBox(height: 12.h),
                  Text(
                    'Select your\ninterests',
                    style: appStyle(
                      32,
                      Colors.black,
                      FontWeight.w900,
                    ).copyWith(letterSpacing: -0.5, height: 1.2),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    'Let others know what you\'re passionate about',
                    style: appStyle(
                      15,
                      Colors.grey[600]!,
                      FontWeight.w400,
                    ).copyWith(letterSpacing: -0.2, height: 1.4),
                  ),

                  SizedBox(height: 16.h),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${selectedInterests.length}/5 selected',
                      style: appStyle(13, Colors.white, FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: availableInterests.map((interest) {
                    final isSelected = selectedInterests.contains(
                      interest['name'],
                    );
                    return _InterestChip(
                      emoji: interest['emoji']!,
                      label: interest['name']!,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          ref
                              .read(onboardingProvider.notifier)
                              .removeInterest(interest['name']!);
                        } else if (selectedInterests.length < 5) {
                          ref
                              .read(onboardingProvider.notifier)
                              .addInterest(interest['name']!);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomButton(
                text: 'Continue',
                onPressed: selectedInterests.isNotEmpty
                    ? () => context.push('/onboarding/complete')
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 0.7,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 8.w),
            Text(
              label,
              style: appStyle(
                14,
                isSelected ? Colors.white : Colors.black,
                isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
