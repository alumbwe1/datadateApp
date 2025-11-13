import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/onboarding_provider.dart';

class OnboardingLocationPage extends ConsumerStatefulWidget {
  const OnboardingLocationPage({super.key});

  @override
  ConsumerState<OnboardingLocationPage> createState() =>
      _OnboardingLocationPageState();
}

class _OnboardingLocationPageState
    extends ConsumerState<OnboardingLocationPage> {
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                'What\'s Your Location?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Help us find matches near you',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.2),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('📍', style: TextStyle(fontSize: 60)),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              CustomTextField(
                label: 'Location',
                hintText: 'Enter your city',
                controller: _locationController,
                prefixIcon: const Icon(Icons.search),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: OutlinedButton.icon(
                  onPressed: () {
                    _locationController.text = 'Current Location';
                  },
                  icon: Icon(
                    Icons.my_location,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Use Current Location',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  if (_locationController.text.isNotEmpty) {
                    ref
                        .read(onboardingProvider.notifier)
                        .setLocation(_locationController.text);
                    context.push('/onboarding/complete');
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
