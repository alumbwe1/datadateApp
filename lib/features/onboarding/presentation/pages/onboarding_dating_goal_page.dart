import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/onboarding_provider.dart';

class OnboardingDatingGoalPage extends ConsumerWidget {
  const OnboardingDatingGoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGoal = ref.watch(onboardingProvider).datingGoal;

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
                'Tell people why you\'re here',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Be confident about what you want, and find the right people for you. You can change this anytime.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              _DatingGoalOption(
                icon: Icons.coffee,
                title: 'Here to date',
                description:
                    'I want to go on dates and have a good time. No labels.',
                isSelected: selectedGoal == 'date',
                onTap: () =>
                    ref.read(onboardingProvider.notifier).setDatingGoal('date'),
              ),
              const SizedBox(height: 16),
              _DatingGoalOption(
                icon: Icons.chat_bubble,
                title: 'Open to chat',
                description:
                    'I\'m here to chat and see where it goes. No pressure.',
                isSelected: selectedGoal == 'chat',
                onTap: () =>
                    ref.read(onboardingProvider.notifier).setDatingGoal('chat'),
              ),
              const SizedBox(height: 16),
              _DatingGoalOption(
                icon: Icons.favorite,
                title: 'Ready for a relationship',
                description: 'I\'m looking for something that lasts. No games.',
                isSelected: selectedGoal == 'relationship',
                onTap: () => ref
                    .read(onboardingProvider.notifier)
                    .setDatingGoal('relationship'),
              ),
              const Spacer(),
              CustomButton(
                text: 'Continue',
                onPressed: selectedGoal != null
                    ? () => context.push('/onboarding/interests')
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatingGoalOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _DatingGoalOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}
