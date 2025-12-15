import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_complete_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_dating_goal_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_gender_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_gender_preference_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_intent_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_interests_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_traits_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import '../../features/onboarding/presentation/pages/profile/onboarding_bio_page.dart';
import '../../features/onboarding/presentation/pages/profile/onboarding_course_page.dart';
import '../../features/onboarding/presentation/pages/profile/onboarding_dob_page.dart';
import '../../features/onboarding/presentation/pages/profile/onboarding_graduation_page.dart';
import '../../features/onboarding/presentation/pages/profile/onboarding_photo_page.dart';
import '../../features/universities/presentation/pages/university_selection_page.dart';
import '../services/analytics_service.dart';
import '../widgets/main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    observers: [AnalyticsService.observer],
    routes: [
      // Splash screen
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      // Onboarding routes
      GoRoute(
        path: '/onboarding/welcome',
        builder: (context, state) => const OnboardingWelcomePage(),
      ),
      GoRoute(
        path: '/onboarding/gender',
        builder: (context, state) => const OnboardingGenderPage(),
      ),
      GoRoute(
        path: '/onboarding/university',
        builder: (context, state) => const UniversitySelectionPage(),
      ),
      GoRoute(
        path: '/onboarding/gender-preference',
        builder: (context, state) => const OnboardingGenderPreferencePage(),
      ),
      GoRoute(
        path: '/onboarding/intent',
        builder: (context, state) => const OnboardingIntentPage(),
      ),
      GoRoute(
        path: '/onboarding/traits',
        builder: (context, state) => const OnboardingTraitsPage(),
      ),
      GoRoute(
        path: '/onboarding/dating-goal',
        builder: (context, state) => const OnboardingDatingGoalPage(),
      ),
      // Profile onboarding routes
      GoRoute(
        path: '/onboarding/profile/photo',
        builder: (context, state) => const OnboardingPhotoPage(),
      ),
      GoRoute(
        path: '/onboarding/profile/dob',
        builder: (context, state) => const OnboardingDobPage(),
      ),
      GoRoute(
        path: '/onboarding/profile/bio',
        builder: (context, state) => const OnboardingBioPage(),
      ),
      GoRoute(
        path: '/onboarding/profile/course',
        builder: (context, state) => const OnboardingCoursePage(),
      ),
      GoRoute(
        path: '/onboarding/profile/graduation',
        builder: (context, state) => const OnboardingGraduationPage(),
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
