import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// Server-side entitlements/usage (GET /v1/entitlements, GET /v1/usage) and restore-purchases
/// (POST /v1/billing/sync). The app never decides premium access itself — every screen that gates a
/// feature reads `Entitlements` from here, never a locally-cached flag (blueprint §13: "a forged
/// mobile flag never unlocks paid API features").
///
/// A real purchase flow (RevenueCat's `purchases_flutter` SDK) is out of scope for this sandboxed
/// environment: there is no real store account or RevenueCat project to purchase against here. This
/// repository covers the server-truth half of the flow (entitlements/usage/restore) that does not
/// require one; see docs/decisions.md and docs/release-checklist.md for what a real release still
/// needs to wire up the actual purchase buttons via the RevenueCat SDK.
abstract interface class BillingRepository {
  Future<Entitlements> fetchEntitlements();
  Future<Usage> fetchUsage();
  Future<Entitlements> restorePurchases();
}

class ApiBillingRepository implements BillingRepository {
  ApiBillingRepository(this._client);
  final NouraApiClient _client;

  BillingApi get _api => _client.getBillingApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<Entitlements> fetchEntitlements() => _guard(() async => (await _api.getEntitlements()).data!.data);

  @override
  Future<Usage> fetchUsage() => _guard(() async => (await _api.getUsage()).data!.data);

  @override
  Future<Entitlements> restorePurchases() =>
      _guard(() async => (await _api.syncBilling(idempotencyKey: newIdempotencyKey())).data!.data);
}

/// Development-only: a free user with the configured free limits. There is no code path that makes
/// this report premium — exercising premium UI in mock mode would misrepresent what a forged client
/// flag can never actually do against the real server.
class MockBillingRepository implements BillingRepository {
  @override
  Future<Entitlements> fetchEntitlements() async => Entitlements(entitlements: []);

  @override
  Future<Usage> fetchUsage() async => Usage(
    timezone: 'UTC',
    features: [
      FeatureUsage(feature: FeatureUsageFeatureEnum.mealScan, period: 'mock', limit: 3, used: 0, reserved: 0),
      FeatureUsage(feature: FeatureUsageFeatureEnum.coachReply, period: 'mock', limit: 5, used: 0, reserved: 0),
    ],
  );

  @override
  Future<Entitlements> restorePurchases() async => Entitlements(entitlements: []);
}
