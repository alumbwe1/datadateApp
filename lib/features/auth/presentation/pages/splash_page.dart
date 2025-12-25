import 'package:datadate/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_style.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    try {
      await ref
          .read(authProvider.notifier)
          .checkAuthStatus()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏱️ Auth check timed out');
            },
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);

      if (authState.user != null) {
        context.go('/encounters');
      } else {
        if (mounted) {
          context.go('/onboarding/welcome');
        }
      }
    } catch (e) {
      debugPrint('❌ Auth check failed: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color(0xFFFF4177),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // App name
              Text(
                'HeartLink',
                style: appStyle(
                  48.sp,
                  Colors.white,
                  FontWeight.w800,
                ).copyWith(letterSpacing: -0.03),
              ),
              
              const Spacer(),
              
              // Loading indicator
              LottieLoadingIndicator(height: 40.h, width: 40.w),
              
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }
}