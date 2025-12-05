import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/onboarding_provider.dart';

class OnboardingTraitsPage extends ConsumerWidget {
  const OnboardingTraitsPage({super.key});

  static const List<Map<String, dynamic>> traits = [
    {'emoji': '💖', 'label': 'Kind', 'value': 'kind'},
    {'emoji': '🤝', 'label': 'Honest', 'value': 'honest'},
    {'emoji': '😄', 'label': 'Funny', 'value': 'funny'},
    {'emoji': '🧠', 'label': 'Intelligent', 'value': 'intelligent'},
    {'emoji': '🎨', 'label': 'Creative', 'value': 'creative'},
    {'emoji': '💪', 'label': 'Ambitious', 'value': 'ambitious'},
    {'emoji': '🌟', 'label': 'Confident', 'value': 'confident'},
    {'emoji': '🤗', 'label': 'Caring', 'value': 'caring'},
    {'emoji': '✨', 'label': 'Adventurous', 'value': 'adventurous'},
    {'emoji': '🎭', 'label': 'Spontaneous', 'value': 'spontaneous'},
    {'emoji': '📚', 'label': 'Educated', 'value': 'educated'},
    {'emoji': '🏃', 'label': 'Active', 'value': 'active'},
    {'emoji': '🎵', 'label': 'Musical', 'value': 'musical'},
    {'emoji': '🍳', 'label': 'Good Cook', 'value': 'good_cook'},
    {'emoji': '💼', 'label': 'Career-Focused', 'value': 'career_focused'},
    {'emoji': '🌍', 'label': 'Traveler', 'value': 'traveler'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using interests as traits for now
    final selectedTraits = ref.watch(
      onboardingProvider.select((state) => state.interests),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    'What traits matter\nmost to you?',
                    style: appStyle(
                      32,
                      Colors.black,
                      FontWeight.w900,
                    ).copyWith(letterSpacing: -0.5, height: 1.2),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Select at least 3 traits you value in a partner.\nThis helps us find better matches.',
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
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: selectedTraits.length >= 3
                                ? Colors.black
                                : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${selectedTraits.length}',
                            style: appStyle(14, Colors.white, FontWeight.w700),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '${selectedTraits.length}/3 selected',
                          style: appStyle(
                            14,
                            Colors.grey[700]!,
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: traits.map((trait) {
                    final isSelected = selectedTraits.contains(trait['value']);
                    return _TraitChip(
                      emoji: trait['emoji'],
                      label: trait['label'],
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (isSelected) {
                          ref
                              .read(onboardingProvider.notifier)
                              .removeInterest(trait['value']);
                        } else {
                          ref
                              .read(onboardingProvider.notifier)
                              .addInterest(trait['value']);
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
                onTap: selectedTraits.length >= 3
                    ? () {
                        HapticFeedback.mediumImpact();
                        context.push('/onboarding/dating-goal');
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

class _TraitChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TraitChip({
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            SizedBox(width: 8.w),
            Text(
              label,
              style: appStyle(
                15,
                isSelected ? Colors.white : Colors.black,
                FontWeight.w600,
              ).copyWith(letterSpacing: -0.2),
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
