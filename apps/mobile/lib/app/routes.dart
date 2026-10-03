/// Route paths. Kept in one place so guards, links and tests agree.
abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signIn = '/auth/phone';
  static const verifyOtp = '/auth/verify-code';
  static const onboarding = '/onboarding';
  static const sessionError = '/session-error';
  static const settings = '/settings';
  static const settingsProfile = '/settings/profile';
  static const settingsGoal = '/settings/goal';
  static const settingsPreferences = '/settings/preferences';
  static const settingsTraining = '/settings/training';
  static const settingsEligibility = '/settings/eligibility';
  static const settingsReminders = '/settings/reminders';
  static const settingsBilling = '/settings/billing';
  static const settingsAccountData = '/settings/account-data';

  static const home = '/home';
  static const meals = '/meals';
  static const dietPlan = '/meals/diet-plan';
  static const mealScan = '/meals/scan';
  static const nextMeal = '/meals/next-meal';
  static const nutritionInsights = '/meals/insights';
  static const coach = '/coach';
  static const workout = '/workout';
  static const progress = '/progress';
  static const weightHistory = '/progress/weight-history';
  static const progressPhotos = '/progress/photos';
  static const progressCompare = '/progress/compare';

  /// Screens reachable without a session.
  static bool isPublic(String location) => location == welcome || location.startsWith('/auth/');
}
