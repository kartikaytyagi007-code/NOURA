import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/account/account_repository.dart';
import 'core/api/api_client.dart';
import 'core/auth/auth_repository.dart';
import 'core/auth/mock_auth_repository.dart';
import 'core/auth/supabase_auth_repository.dart';
import 'core/billing/billing_repository.dart';
import 'core/coach/coach_repository.dart';
import 'core/config/app_config.dart';
import 'core/diet/diet_repository.dart';
import 'core/meals/meal_scan_repository.dart';
import 'core/notifications/notifications_repository.dart';
import 'core/profile/profile_repository.dart';
import 'core/providers.dart';
import 'core/progress/progress_repository.dart';
import 'core/recommendations/recommendations_repository.dart';
import 'core/telemetry/telemetry_provider.dart';
import 'core/workouts/workout_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  final issues = config.validate();
  if (issues.isNotEmpty) {
    runApp(ConfigErrorApp(issues: issues));
    return;
  }

  final AuthRepository auth;
  final ProfileRepository profiles;
  final DietRepository diet;
  final MealScanRepository mealScan;
  final RecommendationsRepository recommendations;
  final WorkoutRepository workouts;
  final ProgressRepository progress;
  final CoachRepository coach;
  final BillingRepository billing;
  final NotificationsRepository notifications;
  final AccountRepository account;
  // No real analytics/crash SDK is wired for V1 (see docs/release-checklist.md): both branches use
  // the in-memory mock, opted out by default, so nothing is ever sent anywhere until a future
  // milestone picks a real provider. This is intentionally never the thing that decides premium
  // access or quota — it is purely observational.
  final TelemetryProvider telemetry = MockTelemetryProvider(enabled: false);
  // Local-only reminders (blueprint §18: "No push infrastructure needed for V1"). Wiring a real
  // `flutter_local_notifications` plugin is out of scope for this milestone (see
  // docs/release-checklist.md); this scheduler safely does nothing rather than guessing at a plugin
  // API that was never exercised on a real device in this environment.
  const reminderScheduler = NoOpReminderScheduler();
  if (config.useMocks) {
    // Explicit development mocks: no network, no real accounts. validate() refuses this outside
    // development debug builds, and the app shows a persistent banner while it is active.
    auth = MockAuthRepository();
    profiles = MockProfileRepository();
    diet = MockDietRepository();
    mealScan = MockMealScanRepository();
    recommendations = MockRecommendationsRepository();
    workouts = MockWorkoutRepository();
    progress = MockProgressRepository();
    coach = MockCoachRepository();
    billing = MockBillingRepository();
    notifications = MockNotificationsRepository();
    account = MockAccountRepository();
  } else {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );
    auth = SupabaseAuthRepository(Supabase.instance.client, redirectUrl: config.authRedirectUrl);
    final apiClient = buildApiClient(buildDio(baseUrl: config.apiBaseUrl, auth: auth));
    profiles = ApiProfileRepository(apiClient);
    diet = ApiDietRepository(apiClient);
    mealScan = ApiMealScanRepository(apiClient);
    recommendations = ApiRecommendationsRepository(apiClient);
    workouts = ApiWorkoutRepository(apiClient);
    progress = ApiProgressRepository(apiClient);
    coach = ApiCoachRepository(apiClient);
    billing = ApiBillingRepository(apiClient);
    notifications = ApiNotificationsRepository(apiClient);
    account = ApiAccountRepository(apiClient);
  }

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
        dietRepositoryProvider.overrideWithValue(diet),
        mealScanRepositoryProvider.overrideWithValue(mealScan),
        recommendationsRepositoryProvider.overrideWithValue(recommendations),
        workoutRepositoryProvider.overrideWithValue(workouts),
        progressRepositoryProvider.overrideWithValue(progress),
        coachRepositoryProvider.overrideWithValue(coach),
        billingRepositoryProvider.overrideWithValue(billing),
        notificationsRepositoryProvider.overrideWithValue(notifications),
        reminderSchedulerProvider.overrideWithValue(reminderScheduler),
        accountRepositoryProvider.overrideWithValue(account),
        telemetryProvider.overrideWithValue(telemetry),
      ],
      child: const NouraApp(),
    ),
  );
}
