import 'dart:convert';

import 'package:flutter/foundation.dart';

enum AppEnvironment { development, staging, production }

/// Public, build-time configuration supplied with `--dart-define` (or `--dart-define-from-file`).
///
/// Only public values belong here: API base URL, Supabase URL and its *publishable* key, and
/// feature switches. Server secrets (service-role/secret keys, AI keys, RevenueCat secret keys) must
/// never be compiled into the app; [validate] refuses keys that look privileged.
@immutable
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.authRedirectUrl,
    required this.useMocks,
    required this.googleSignInEnabled,
    required this.appleSignInEnabled,
    required this.devBypassOnboarding,
    this.environmentName,
  });

  factory AppConfig.fromEnvironment() {
    const env = String.fromEnvironment('NOURA_ENV', defaultValue: 'development');
    return AppConfig(
      environment: parseEnvironment(env),
      environmentName: env,
      apiBaseUrl: const String.fromEnvironment('NOURA_API_BASE_URL'),
      supabaseUrl: const String.fromEnvironment('NOURA_SUPABASE_URL'),
      supabasePublishableKey: const String.fromEnvironment('NOURA_SUPABASE_PUBLISHABLE_KEY'),
      authRedirectUrl: const String.fromEnvironment('NOURA_AUTH_REDIRECT_URL', defaultValue: 'noura://auth-callback'),
      useMocks: const bool.fromEnvironment('NOURA_USE_MOCKS'),
      googleSignInEnabled: const bool.fromEnvironment('NOURA_GOOGLE_SIGN_IN_ENABLED'),
      appleSignInEnabled: const bool.fromEnvironment('NOURA_APPLE_SIGN_IN_ENABLED'),
      devBypassOnboarding: const bool.fromEnvironment('NOURA_DEV_BYPASS_ONBOARDING'),
    );
  }

  final AppEnvironment? environment;
  final String? environmentName;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String authRedirectUrl;

  /// Explicit development mocks for auth and API. Never allowed outside development.
  final bool useMocks;
  final bool googleSignInEnabled;
  final bool appleSignInEnabled;

  /// Development-only escape hatch to view the app shell before onboarding exists (M2).
  final bool devBypassOnboarding;

  bool get isDevelopment => environment == AppEnvironment.development;

  static AppEnvironment? parseEnvironment(String value) {
    for (final e in AppEnvironment.values) {
      if (e.name == value) return e;
    }
    return null;
  }

  /// Returns human-readable configuration problems. An empty list means the app may start.
  /// Fails closed: anything unsafe in staging/production, or in a release build, is an issue.
  List<String> validate({bool releaseMode = kReleaseMode}) {
    final issues = <String>[];
    if (environment == null) {
      issues.add('NOURA_ENV "${environmentName ?? ''}" is not one of development, staging, production.');
      return issues;
    }
    if (useMocks && (!isDevelopment || releaseMode)) {
      issues.add('NOURA_USE_MOCKS is only allowed in development debug builds.');
    }
    if (devBypassOnboarding && (!isDevelopment || releaseMode)) {
      issues.add('NOURA_DEV_BYPASS_ONBOARDING is only allowed in development debug builds.');
    }
    if (looksPrivileged(supabasePublishableKey)) {
      issues.add('NOURA_SUPABASE_PUBLISHABLE_KEY looks like a privileged server key. Never ship it in the app.');
    }
    if (useMocks && isDevelopment && !releaseMode) return issues;

    final requireHttps = !isDevelopment;
    if (!_isValidUrl(apiBaseUrl, requireHttps: requireHttps)) {
      issues.add('NOURA_API_BASE_URL must be a valid ${requireHttps ? 'https' : 'http(s)'} URL.');
    }
    if (!_isValidUrl(supabaseUrl, requireHttps: requireHttps)) {
      issues.add('NOURA_SUPABASE_URL must be a valid ${requireHttps ? 'https' : 'http(s)'} URL.');
    }
    if (supabasePublishableKey.isEmpty) {
      issues.add('NOURA_SUPABASE_PUBLISHABLE_KEY is required.');
    }
    if (Uri.tryParse(authRedirectUrl)?.hasScheme != true) {
      issues.add('NOURA_AUTH_REDIRECT_URL must be an absolute URL (for example noura://auth-callback).');
    }
    return issues;
  }

  static bool _isValidUrl(String value, {required bool requireHttps}) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority) return false;
    return requireHttps ? uri.scheme == 'https' : (uri.scheme == 'https' || uri.scheme == 'http');
  }

  /// Detects Supabase secret keys and legacy service-role JWTs.
  static bool looksPrivileged(String key) {
    if (key.startsWith('sb_secret_')) return true;
    final parts = key.split('.');
    if (parts.length != 3) return false;
    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = jsonDecode(payload);
      return claims is Map && claims['role'] == 'service_role';
    } on FormatException {
      return false;
    }
  }
}
