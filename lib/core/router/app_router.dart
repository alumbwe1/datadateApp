import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_gender_preference_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_traits_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_dating_goal_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_interests_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_complete_page.dart';
import '../widgets/main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      // Onboarding routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingWelcomePage(),
      ),
      GoRoute(
        path: '/onboarding/gender-preference',
        builder: (context, state) => const OnboardingGenderPreferencePage(),
      ),
      GoRoute(
        path: '/onboarding/traits',
        builder: (context, state) => const OnboardingTraitsPage(),
      ),
      GoRoute(
        path: '/onboarding/dating-goal',
        builder: (context, state) => const OnboardingDatingGoalPage(),
      ),
      GoRoute(
        path: '/onboarding/interests',
        builder: (context, state) => const OnboardingInterestsPage(),
      ),
      GoRoute(
        path: '/onboarding/complete',
        builder: (context, state) => const OnboardingCompletePage(),
      ),
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // Main app route - single route with bottom navigation
      GoRoute(
        path: '/encounters',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainNavigation(),
      ),
    ],
  );
}
