import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/config/app_config.dart';

import '../support/harness.dart';

String _jwt(Map<String, Object> claims) {
  String part(Map<String, Object> m) => base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part(claims)}.signature';
}

void main() {
  group('AppConfig.validate', () {
    test('accepts a complete development configuration', () {
      expect(testConfig().validate(releaseMode: false), isEmpty);
    });

    test('accepts a complete production configuration', () {
      final config = testConfig(
        environment: AppEnvironment.production,
        apiBaseUrl: 'https://api.example.com',
        supabaseUrl: 'https://project.supabase.co',
      );
      expect(config.validate(releaseMode: true), isEmpty);
    });

    test('mocks are allowed only in development debug builds (fail closed)', () {
      expect(
        testConfig(useMocks: true, apiBaseUrl: '', supabaseUrl: '', publishableKey: '').validate(releaseMode: false),
        isEmpty,
      );
      expect(testConfig(useMocks: true).validate(releaseMode: true), contains(contains('NOURA_USE_MOCKS')));
      for (final env in [AppEnvironment.staging, AppEnvironment.production]) {
        final issues = testConfig(environment: env, useMocks: true).validate(releaseMode: false);
        expect(issues, contains(contains('NOURA_USE_MOCKS')));
      }
      expect(
        testConfig(environment: AppEnvironment.production, devBypassOnboarding: true).validate(releaseMode: true),
        contains(contains('NOURA_DEV_BYPASS_ONBOARDING')),
      );
    });

    test('staging and production require https and a publishable key', () {
      final issues = testConfig(environment: AppEnvironment.staging, publishableKey: '').validate(releaseMode: true);
      expect(issues, contains(contains('NOURA_API_BASE_URL')));
      expect(issues, contains(contains('NOURA_SUPABASE_URL')));
      expect(issues, contains(contains('NOURA_SUPABASE_PUBLISHABLE_KEY is required')));
    });

    test('refuses privileged Supabase keys in the app', () {
      expect(AppConfig.looksPrivileged('sb_secret_abc'), isTrue);
      expect(AppConfig.looksPrivileged(_jwt({'role': 'service_role'})), isTrue);
      expect(AppConfig.looksPrivileged(_jwt({'role': 'anon'})), isFalse);
      expect(AppConfig.looksPrivileged('sb_publishable_abc'), isFalse);
      expect(
        testConfig(publishableKey: 'sb_secret_abc').validate(releaseMode: false),
        contains(contains('privileged')),
      );
    });

    test('rejects an unknown environment name', () {
      expect(testConfig(environment: null).validate(releaseMode: false), contains(contains('NOURA_ENV')));
    });
  });
}
