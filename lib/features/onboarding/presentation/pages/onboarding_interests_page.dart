import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/onboarding_provider.dart';

class OnboardingInterestsPage extends ConsumerWidget {
  const OnboardingInterestsPage({super.key});

  static const List<String> availableInterests = [
    'Photography',
    'Music',
    'Travel',
    'Fitness',
    'Cooking',
    'Art',
    'Reading',
    'Gaming',
    'Movies',
    'Sports',
    'Dancing',
    'Technology',
    'Fashion',
    'Nature',
    'Yoga',
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableInterests.map((interest) {
                      final isSelected = selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected && selectedInterests.length < 5) {
                            ref
                                .read(onboardingProvider.notifier)
                                .addInterest(interest);
                          } else if (!selected) {
                            ref
                                .read(onboardingProvider.notifier)
                                .removeInterest(interest);
                          }
                        },
                        selectedColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : null,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Continue',
                onPressed: selectedInterests.isNotEmpty
                    ? () => context.push('/onboarding/location')
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
