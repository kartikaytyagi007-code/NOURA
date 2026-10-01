import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noura/core/api/api_client.dart';
import 'package:noura/core/api/api_failure.dart';
import 'package:noura/core/auth/auth_state.dart';
import 'package:noura/core/auth/mock_auth_repository.dart';
import 'package:noura/core/profile/profile_repository.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../support/fake_profile_server.dart';

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
        initial: const SignedIn(userId: MockAuthRepository.mockUserId, email: 'a@example.com'),
      );
  @override
  Future<String?> accessToken() async => 'token';
}

Map<String, Object?> _meJson(FakeProfileServer server) => {
  'data': server.me.toJson(),
  'meta': {'request_id': 'r'},
};

Map<String, Object?> _body(RequestOptions r) => jsonDecode(r.data as String) as Map<String, Object?>;

ApiProfileRepository _repo(_Adapter adapter) =>
    ApiProfileRepository(buildApiClient(buildDio(baseUrl: 'http://api.test', auth: _Auth(), adapter: adapter)));

void main() {
  final server = FakeProfileServer(initial: FakeProfileServer.completedMe());

  test('patchMe sends the expected revision and an idempotency key, never a user id', () async {
    final adapter = _Adapter([(200, _meJson(server))]);
    await _repo(adapter).patchProfile(
      ProfilePatch(
        expectedRevision: 9,
        calculationSex: CalculationSexInput.declined,
        screening: ScreeningAnswers(
          pregnancyOrBreastfeeding: ScreeningAnswer.yes,
          eatingDisorderConcern: ScreeningAnswer.no,
          medicalDietCondition: ScreeningAnswer.preferNotToSay,
        ),
        onboardingStep: OnboardingStep.review,
      ),
      idempotencyKey: 'key-0001-abcdef',
    );
    final sent = adapter.requests.single;
    expect(sent.method, 'PATCH');
    expect(sent.uri.path, '/v1/me');
    expect(sent.headers['Idempotency-Key'], 'key-0001-abcdef');
    expect(_body(sent), {
      'expected_revision': 9,
      'calculation_sex': 'declined',
      'screening': {
        'pregnancy_or_breastfeeding': 'yes',
        'eating_disorder_concern': 'no',
        'medical_diet_condition': 'prefer_not_to_say',
      },
      'onboarding_step': 'review',
    });
    expect(sent.data as String, isNot(contains('user_id')));
  });

  test('a generated key is used when none is given, and is unique per call', () async {
    final adapter = _Adapter([(200, _meJson(server)), (200, _meJson(server))]);
    final repo = _repo(adapter);
    await repo.patchProfile(ProfilePatch(expectedRevision: 9, displayName: 'A'));
    await repo.patchProfile(ProfilePatch(expectedRevision: 9, displayName: 'A'));
    final keys = adapter.requests.map((r) => r.headers['Idempotency-Key']! as String).toList();
    expect(keys[0], matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(keys[0], isNot(keys[1]));
  });

  test('preferences and training are whole-object PUTs starting at revision 0', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': server.me.preferences!.toJson(),
          'meta': {'request_id': 'r'},
        },
      ),
      (
        200,
        {
          'data': server.me.trainingPreferences!.toJson(),
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final repo = _repo(adapter);
    await repo.savePreferences(
      PreferencesInput(
        expectedRevision: 0,
        dietType: DietType.vegan,
        allergyIds: {AllergyTag.treeNut},
        exclusionIds: {},
        cuisines: {CuisineTag.southIndian},
        budgetBand: BudgetBand.low,
        cookingTime: CookingTime.minimal,
        mealsPerDay: 3,
      ),
    );
    await repo.saveTraining(
      TrainingPreferencesInput(
        expectedRevision: 0,
        experience: ExperienceLevel.advanced,
        location: TrainingLocation.gym,
        equipmentIds: {},
        weekdays: {2, 4},
        daysPerWeek: 2,
        durationMinutes: 60,
        limitationTags: {LimitationTag.knee},
      ),
    );
    expect(adapter.requests[0].method, 'PUT');
    expect(adapter.requests[0].uri.path, '/v1/me/preferences');
    expect(_body(adapter.requests[0]), containsPair('allergy_ids', ['tree_nut']));
    expect(_body(adapter.requests[0]), containsPair('expected_revision', 0));
    expect(adapter.requests[1].uri.path, '/v1/me/training-preferences');
    expect(_body(adapter.requests[1]), containsPair('weekdays', [2, 4]));
    expect(_body(adapter.requests[1]), containsPair('limitation_tags', ['knee']));
  });

  test('completeOnboarding sends the revision, consent versions and the key', () async {
    final adapter = _Adapter([
      (
        200,
        {
          'data': {'me': server.me.toJson(), 'job_ids': <String>[]},
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final result = await _repo(adapter).completeOnboarding(
      OnboardingCompleteRequest(
        expectedRevision: 8,
        consents: [ConsentInput(consentType: ConsentType.terms, version: kDraftConsentVersion)],
      ),
      idempotencyKey: 'done-key-123456',
    );
    expect(result.jobIds, isEmpty);
    final sent = adapter.requests.single;
    expect(sent.uri.path, '/v1/onboarding/complete');
    expect(sent.headers['Idempotency-Key'], 'done-key-123456');
    expect(_body(sent), {
      'expected_revision': 8,
      'consents': [
        {'consent_type': 'terms', 'version': 'v0-draft'},
      ],
    });
  });

  test('a 409 becomes a conflict failure and a 422 keeps its field errors', () async {
    final adapter = _Adapter([
      (
        409,
        {
          'error': {'code': 'REVISION_CONFLICT', 'message': 'changed', 'field_errors': <Object>[], 'retryable': false},
          'meta': {'request_id': 'r'},
        },
      ),
      (
        422,
        {
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Request validation failed.',
            'field_errors': [
              {'field': 'body.weight_kg', 'code': 'maximum', 'message': 'must be <= 400'},
            ],
            'retryable': false,
          },
          'meta': {'request_id': 'r'},
        },
      ),
    ]);
    final repo = _repo(adapter);
    await expectLater(
      repo.patchProfile(ProfilePatch(expectedRevision: 1, displayName: 'A')),
      throwsA(isA<ApiFailure>().having((f) => f.kind, 'kind', ApiFailureKind.conflict)),
    );
    await expectLater(
      repo.patchProfile(ProfilePatch(expectedRevision: 1, displayName: 'A')),
      throwsA(
        isA<ApiFailure>()
            .having((f) => f.kind, 'kind', ApiFailureKind.validation)
            .having((f) => f.fieldErrors.single.field, 'field', 'body.weight_kg'),
      ),
    );
  });

  test('the development mock applies revision rules and never fabricates plans', () async {
    final mock = MockProfileRepository();
    final me = await mock.fetchMe();
    expect(me.planning, isNull);
    final patched = await mock.patchProfile(ProfilePatch(expectedRevision: 1, displayName: 'Asha'));
    expect(patched.profile.revision, 2);
    await expectLater(
      mock.patchProfile(ProfilePatch(expectedRevision: 1, displayName: 'Again')),
      throwsA(isA<ApiFailure>().having((f) => f.kind, 'kind', ApiFailureKind.conflict)),
    );
    final done = await mock.completeOnboarding(OnboardingCompleteRequest(expectedRevision: 2, consents: const []));
    expect(done.jobIds, isEmpty);
    expect(done.me.planning!.status, PlanningStatus.unavailablePolicy);
    expect(done.me.eligibilityStatus, isNull, reason: 'the mock computes no eligibility');
  });
}
