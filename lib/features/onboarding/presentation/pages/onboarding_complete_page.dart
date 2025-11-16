import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';
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
  bool _isRegistering = false;

  Future<void> _handleComplete() async {
    setState(() => _isRegistering = true);

    final onboardingState = ref.read(onboardingProvider);

    // Register the user with all collected information
    await ref
        .read(authProvider.notifier)
        .register(
          email: onboardingState.email!,
          password: onboardingState.password!,
          name: onboardingState.name!,
          age: onboardingState.age!,
          gender: onboardingState.gender!,
          university: onboardingState.universityId?.toString() ?? '1',
          relationshipGoal: onboardingState.datingGoal ?? 'date',
        );

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        await ref.read(onboardingProvider.notifier).completeOnboarding();
        if (mounted) {
          context.go('/encounters');
        }
      } else if (authState.error != null) {
        setState(() => _isRegistering = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authState.error!,
                style: appStyle(14, Colors.white, FontWeight.w600),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              Center(
                child: Container(
                  width: 160.w,
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('🎉', style: TextStyle(fontSize: 80.sp)),
                  ),
                ),
              ),

              SizedBox(height: 48.h),

              Text(
                'You\'re All Set!',
                style: appStyle(
                  36,
                  Colors.black,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20.h),

              Text(
                'Start exploring and connect with\nthe campus elite',
                style: appStyle(
                  16,
                  Colors.grey[600]!,
                  FontWeight.w400,
                ).copyWith(height: 1.5, letterSpacing: -0.2),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              CustomButton(
                text: 'Start Exploring',
                onPressed: _isRegistering ? null : _handleComplete,
                isLoading: _isRegistering,
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
