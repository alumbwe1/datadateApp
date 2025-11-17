import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../providers/auth_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

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
    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user is logged in
    await ref.read(authProvider.notifier).checkAuthStatus();
    final authState = ref.read(authProvider);

    if (authState.user != null) {
      // User is logged in, check if onboarding is completed
      final hasCompletedOnboarding = await ref
          .read(onboardingProvider.notifier)
          .hasCompletedOnboarding();

      if (mounted) {
        if (hasCompletedOnboarding) {
          // Go directly to home
          context.go('/encounters');
        } else {
          // Complete onboarding
          context.go('/onboarding/welcome');
        }
      }
    } else {
      // Not logged in, go to login
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/dataDate.png',
              height: 100,
              width: 100,
              color: Colors.black,
            ),
            const SizedBox(height: 24),
            Text(
              'DataDate',
              style: appStyle(
                32,
                Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
