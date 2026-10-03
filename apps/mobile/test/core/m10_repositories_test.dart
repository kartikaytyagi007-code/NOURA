import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/account/account_repository.dart';
import 'package:noura/core/api/api_client.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/billing/billing_repository.dart';
import 'package:noura/core/notifications/notifications_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.responses);
  final List<(int, Map<String, Object?>)> responses;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Auth extends MockAuthRepository {
  _Auth()
    : super(
        initial: const SignedIn(userId: MockAuthRepository.mockUserId, phone: '+919876543210'),
      );
  @override
  Future<String?> accessToken() async => 'token';
}

Map<String, Object?> _body(RequestOptions r) => jsonDecode(r.data as String) as Map<String, Object?>;

NouraApiClient _client(_Adapter adapter) =>
    buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: adapter));

void main() {
  group('ApiBillingRepository', () {
    test('fetchEntitlements reads the server-verified entitlement list', () async {
      final adapter = _Adapter([
        (
          200,
          {
            'data': {
              'entitlements': [
                {
                  'key': 'premium',
                  'is_active': true,
                  'provider_status': 'active',
                  'expires_at': null,
                  'last_verified_at': '2026-10-01T00:00:00Z',
                },
              ],
            },
            'meta': {'request_id': 'r'},
          },
        ),
      ]);
      final entitlements = await ApiBillingRepository(_client(adapter)).fetchEntitlements();
      expect(entitlements.entitlements.single.key, 'premium');
      expect(adapter.requests.single.path, '/v1/entitlements');
    });

    test('restorePurchases sends an Idempotency-Key and returns the reconciled entitlements', () async {
      final adapter = _Adapter([
        (
          200,
          {
            'data': {'entitlements': <Object?>[]},
            'meta': {'request_id': 'r'},
          },
        ),
      ]);
      final entitlements = await ApiBillingRepository(_client(adapter)).restorePurchases();
      expect(entitlements.entitlements, isEmpty);
      final sent = adapter.requests.single;
      expect(sent.method, 'POST');
      expect(sent.path, '/v1/billing/sync');
      expect(sent.headers.containsKey('Idempotency-Key'), isTrue);
    });
  });

  group('MockBillingRepository', () {
    test('never reports a premium entitlement', () async {
      final entitlements = await MockBillingRepository().fetchEntitlements();
      expect(entitlements.entitlements, isEmpty);
    });
  });

  group('ApiNotificationsRepository', () {
    test('save sends the expected revision and consent timestamp, never a user id', () async {
      final adapter = _Adapter([
        (
          200,
          {
            'data': {
              'revision': 1,
              'meal_reminders_enabled': true,
              'workout_reminders_enabled': false,
              'meal_reminder_time': '08:00',
              'workout_reminder_time': null,
              'consent_granted_at': '2026-10-03T00:00:00Z',
            },
            'meta': {'request_id': 'r'},
          },
        ),
      ]);
      final saved = await ApiNotificationsRepository(_client(adapter)).save(
        NotificationPreferencesInput(
          expectedRevision: 0,
          mealRemindersEnabled: true,
          workoutRemindersEnabled: false,
          mealReminderTime: '08:00',
          consentGrantedAt: DateTime.utc(2026, 10, 3),
        ),
      );
      expect(saved.revision, 1);
      expect(saved.mealRemindersEnabled, isTrue);
      final sent = adapter.requests.single;
      expect(sent.path, '/v1/me/notification-preferences');
      expect(_body(sent)['expected_revision'], 0);
      expect(_body(sent).containsKey('user_id'), isFalse);
    });
  });

  group('NoOpReminderScheduler', () {
    test('never throws and schedules nothing', () async {
      const scheduler = NoOpReminderScheduler();
      await scheduler.applyPreferences(
        NotificationPreferences(
          revision: 0,
          mealRemindersEnabled: true,
          workoutRemindersEnabled: true,
          mealReminderTime: '08:00',
          workoutReminderTime: '18:00',
          consentGrantedAt: null,
        ),
        timezone: 'UTC',
      );
      await scheduler.cancelAll();
    });
  });

  group('ApiAccountRepository', () {
    test('requestExport is idempotent and returns the accepted job', () async {
      final adapter = _Adapter([
        (
          202,
          {
            'data': {'export_id': 'exp-1', 'job_id': 'job-1'},
            'meta': {'request_id': 'r'},
          },
        ),
      ]);
      final accepted = await ApiAccountRepository(_client(adapter)).requestExport();
      expect(accepted.exportId, 'exp-1');
      final sent = adapter.requests.single;
      expect(sent.method, 'POST');
      expect(sent.headers.containsKey('Idempotency-Key'), isTrue);
    });

    test('deleteAccount sends the required confirmation literal', () async {
      final adapter = _Adapter([
        (
          202,
          {
            'data': {'deletion_request_id': 'del-1', 'state': 'requested'},
            'meta': {'request_id': 'r'},
          },
        ),
      ]);
      final accepted = await ApiAccountRepository(_client(adapter)).deleteAccount();
      expect(accepted.deletionRequestId, 'del-1');
      final sent = adapter.requests.single;
      expect(_body(sent)['confirm'], 'DELETE_MY_ACCOUNT');
    });
  });

  group('MockAccountRepository', () {
    test('never fabricates a completed export', () async {
      final export = await MockAccountRepository().getExport('any');
      expect(export.state, AccountExportStateEnum.completed);
      expect(export.downloadUrl, isNull);
    });
  });
}
