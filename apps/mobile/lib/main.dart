import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/api/api_client.dart';
import 'core/auth/auth_repository.dart';
import 'core/auth/mock_auth_repository.dart';
import 'core/auth/supabase_auth_repository.dart';
import 'core/config/app_config.dart';
import 'core/profile/session_profile.dart';
import 'core/providers.dart';

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
  if (config.useMocks) {
    // Explicit development mocks: no network, no real accounts. validate() refuses this outside
    // development debug builds, and the app shows a persistent banner while it is active.
    auth = MockAuthRepository();
    profiles = MockProfileRepository();
  } else {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );
    auth = SupabaseAuthRepository(Supabase.instance.client, redirectUrl: config.authRedirectUrl);
    profiles = ApiProfileRepository(buildApiClient(buildDio(baseUrl: config.apiBaseUrl, auth: auth)));
  }

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
      ],
      child: const NouraApp(),
    ),
  );
}
