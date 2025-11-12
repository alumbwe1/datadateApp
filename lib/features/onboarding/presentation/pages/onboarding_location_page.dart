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
                'Enter Your Location',
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
              const SizedBox(height: 32),
              Icon(
                Icons.location_on,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Location',
                hint: 'Enter your city',
                controller: _locationController,
                prefixIcon: const Icon(Icons.search),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // In a real app, this would use location services
                  _locationController.text = 'Current Location';
                },
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
            ],
          ),
        ),
      ),
    );
  }
}
