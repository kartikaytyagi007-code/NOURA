/// Route paths. Kept in one place so guards, links and tests agree.
abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const verifyEmail = '/auth/verify-email';
  static const forgotPassword = '/auth/forgot-password';
  static const updatePassword = '/auth/update-password';
  static const onboarding = '/onboarding';
  static const sessionError = '/session-error';
  static const settings = '/settings';
  static const settingsProfile = '/settings/profile';
  static const settingsGoal = '/settings/goal';
  static const settingsPreferences = '/settings/preferences';
  static const settingsTraining = '/settings/training';
  static const settingsEligibility = '/settings/eligibility';

  static const home = '/home';
  static const meals = '/meals';
  static const dietPlan = '/meals/diet-plan';
  static const mealScan = '/meals/scan';
  static const coach = '/coach';
  static const workout = '/workout';
  static const progress = '/progress';

  /// Screens reachable without a session.
  static bool isPublic(String location) => location == welcome || location.startsWith('/auth/');
}
