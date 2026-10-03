import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/profile/session_profile.dart';
import '../core/providers.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/update_password_screen.dart';
import '../features/auth/presentation/verify_email_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/coach/coach_screen.dart';
import '../features/diet/diet_plan_screen.dart';
import '../features/home/home_screen.dart';
import '../features/meals/meal_scan_screen.dart';
import '../features/meals/meals_screen.dart';
import '../features/meals/next_meal_screen.dart';
import '../features/meals/nutrition_insights_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/session/session_error_screen.dart';
import '../features/session/splash_screen.dart';
import '../features/settings/profile_settings_pages.dart';
import '../features/settings/settings_screen.dart';
import '../features/workouts/workout_screen.dart';
import 'route_guard.dart';
import 'routes.dart';
import 'shell.dart';

/// Maps the profile request to the router's view of it. An error wins over a retry in flight so
/// the error screen stays put (with its retry button) instead of flashing the splash screen.
ProfileGate profileGateOf(AsyncValue<SessionProfile?> value) {
  if (value.hasError) return const ProfileFailed();
  final profile = value.value;
  if (value.isLoading || profile == null) return const ProfileLoading();
  return ProfileReady(profile);
}

/// One router for the app's lifetime. Auth or profile changes only trigger a redirect
/// re-evaluation (refreshListenable); the policy itself is the pure [resolveRedirect].
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.listen(sessionProfileProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      location: state.matchedLocation,
      auth: ref.read(authControllerProvider),
      profile: profileGateOf(ref.read(sessionProfileProvider)),
      devBypassOnboarding: ref.read(appConfigProvider).devBypassOnboarding,
    ),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: Routes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (_, state) => VerifyEmailScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(path: Routes.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: Routes.updatePassword, builder: (_, _) => const UpdatePasswordScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.sessionError, builder: (_, _) => const SessionErrorScreen()),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => const SettingsScreen(),
        routes: [
          GoRoute(path: 'profile', builder: (_, _) => const ProfileEditPage()),
          GoRoute(path: 'goal', builder: (_, _) => const GoalEditPage()),
          GoRoute(path: 'preferences', builder: (_, _) => const PreferencesEditPage()),
          GoRoute(path: 'training', builder: (_, _) => const TrainingEditPage()),
          GoRoute(path: 'eligibility', builder: (_, _) => const EligibilityEditPage()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.meals,
                builder: (_, _) => const MealsScreen(),
                routes: [
                  GoRoute(path: 'diet-plan', builder: (_, _) => const DietPlanScreen()),
                  GoRoute(path: 'scan', builder: (_, _) => const MealScanScreen()),
                  GoRoute(path: 'next-meal', builder: (_, _) => const NextMealScreen()),
                  GoRoute(path: 'insights', builder: (_, _) => const NutritionInsightsScreen()),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.coach, builder: (_, _) => const CoachScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.workout, builder: (_, _) => const WorkoutScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.progress, builder: (_, _) => const ProgressScreen())],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
