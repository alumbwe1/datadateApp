import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/password_error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingCompletePage extends ConsumerStatefulWidget {
  const OnboardingCompletePage({super.key});

  @override
  ConsumerState<OnboardingCompletePage> createState() =>
      _OnboardingCompletePageState();
}

class _OnboardingCompletePageState
    extends ConsumerState<OnboardingCompletePage> {
  bool _isCompleting = false;

  Future<void> _completeOnboarding() async {
    setState(() => _isCompleting = true);

    final onboardingState = ref.read(onboardingProvider);

    // First, register the user
    if (onboardingState.email != null &&
        onboardingState.password != null &&
        onboardingState.name != null) {
      // Register user (intent and preferred genders will be set during profile update)
      final result = await ref
          .read(authProvider.notifier)
          .register(
            email: onboardingState.email!,
            password: onboardingState.password!,
            name: onboardingState.name!,
          );

      if (!mounted) return;

      await result.fold(
        (failure) async {
          setState(() => _isCompleting = false);

          // Check if it's a password error
          if (failure.message.toLowerCase().contains('password')) {
            PasswordErrorBottomSheet.show(
              context,
              errorMessage: failure.message,
              onRetry: () {
                // Go back to register page
                context.go('/register');
              },
            );
          } else {
            CustomSnackbar.show(
              context,
              message: failure.message,
              type: SnackbarType.error,
            );
          }
        },
        (_) async {
          // Registration successful, now update profile
          print('🎯 Starting profile update...');
          final success = await ref
              .read(onboardingProvider.notifier)
              .completeOnboarding();

          print('🎯 Profile update result: $success');

          if (!mounted) {
            print('⚠️ Widget not mounted, returning');
            return;
          }

          if (success) {
            print('✅ Profile completed successfully, navigating...');
            CustomSnackbar.show(
              context,
              message: 'Profile completed successfully!',
              type: SnackbarType.success,
            );

            // Small delay to ensure snackbar shows
            await Future.delayed(const Duration(milliseconds: 500));

            if (!mounted) return;

            // Navigate to home
            print('🚀 Navigating to /encounters');
            context.go('/encounters');
          } else {
            print('❌ Profile update failed');
            setState(() => _isCompleting = false);

            final error = ref.read(onboardingProvider).error;
            CustomSnackbar.show(
              context,
              message: error ?? 'Failed to complete profile',
              type: SnackbarType.error,
            );
          }
        },
      );
    } else {
      setState(() => _isCompleting = false);
      CustomSnackbar.show(
        context,
        message: 'Missing registration data. Please start over.',
        type: SnackbarType.error,
      );
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success animation
              Lottie.asset(
                'assets/lottie/success.json',
                height: 200.h,
                repeat: false,
              ),

              SizedBox(height: 32.h),

              Text(
                'You\'re All Set! 🎉',
                style: appStyle(
                  32,
                  Colors.black,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              Text(
                'Your profile is ready. Start exploring and find your perfect match!',
                style: appStyle(
                  16,
                  Colors.grey[600]!,
                  FontWeight.w400,
                ).copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              CustomButton(
                text: _isCompleting ? 'Completing...' : 'Start Exploring',
                onPressed: _isCompleting ? null : _completeOnboarding,
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
