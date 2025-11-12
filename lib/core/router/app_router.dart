import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/encounters/presentation/pages/encounters_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_dating_goal_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_interests_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_location_page.dart';
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
        path: '/onboarding/dating-goal',
        builder: (context, state) => const OnboardingDatingGoalPage(),
      ),
      GoRoute(
        path: '/onboarding/interests',
        builder: (context, state) => const OnboardingInterestsPage(),
      ),
      GoRoute(
        path: '/onboarding/location',
        builder: (context, state) => const OnboardingLocationPage(),
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
      // Main app routes
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: '/encounters',
            builder: (context, state) => EncountersPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
