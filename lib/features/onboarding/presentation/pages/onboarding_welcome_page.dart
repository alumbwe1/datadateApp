import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';

class OnboardingWelcomePage extends ConsumerWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              Image.asset(
                'assets/images/dataDate.png',
                height: 100.h,
                width: 100.w,
                color: Colors.black,
              ),

              SizedBox(height: 32.h),

              Text(
                'Welcome to DataDate! 🎉',
                style: appStyle(
                  32,
                  Colors.black,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              Text(
                'Let\'s set up your profile to help you find the perfect match',
                style: appStyle(
                  16,
                  Colors.grey[600]!,
                  FontWeight.w400,
                ).copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              CustomButton(
                text: 'Get Started',
                onPressed: () {
                  context.push('/onboarding/gender-preference');
                },
              ),

              SizedBox(height: 16.h),

              TextButton(
                onPressed: () {
                  // Skip to home (will have incomplete profile)
                  context.go('/encounters');
                },
                child: Text(
                  'Skip for now',
                  style: appStyle(15, Colors.grey[600]!, FontWeight.w600),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
