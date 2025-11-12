import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/onboarding_provider.dart';

class OnboardingCompletePage extends ConsumerWidget {
  const OnboardingCompletePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.check_circle,
                size: 120,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              Text(
                'You\'re All Set!',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Start exploring and find your perfect match',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CustomButton(
                text: 'Start Exploring',
                onPressed: () async {
                  await ref
                      .read(onboardingProvider.notifier)
                      .completeOnboarding();
                  if (context.mounted) {
                    context.go('/register');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
