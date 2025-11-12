import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
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
    {'name': 'Dancing', 'emoji': '💃'},
    {'name': 'Technology', 'emoji': '💻'},
    {'name': 'Fashion', 'emoji': '👗'},
    {'name': 'Nature', 'emoji': '🌿'},
    {'name': 'Yoga', 'emoji': '🧘'},
    {'name': 'Coffee', 'emoji': '☕'},
    {'name': 'Pets', 'emoji': '🐶'},
    {'name': 'Wine', 'emoji': '🍷'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInterests = ref.watch(onboardingProvider).interests;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select up to 5 interests',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Let others know what you\'re passionate about',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedInterests.length}/5 selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
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
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                text: 'Continue',
                onPressed: selectedInterests.isNotEmpty
                    ? () => context.push('/onboarding/location')
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                )
              : null,
          color: isSelected ? null : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
