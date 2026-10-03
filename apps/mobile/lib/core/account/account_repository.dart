import 'package:dio/dio.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../profile/profile_repository.dart' show newIdempotencyKey;

/// Data export and account deletion (blueprint §14). Deletion is a 202-accepted async job — the
/// server revokes access, cancels queued jobs, removes Storage objects and owned rows, then deletes
/// the auth identity (apps/worker's `account.delete` handler). This repository only starts/reads
/// those jobs; it never fabricates a completed state.
abstract interface class AccountRepository {
  Future<ExportAccepted> requestExport();
  Future<AccountExport> getExport(String id);
  Future<DeletionAccepted> deleteAccount();
}

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._client);
  final NouraApiClient _client;

  AccountApi get _api => _client.getAccountApi();

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  @override
  Future<ExportAccepted> requestExport() =>
      _guard(() async => (await _api.requestAccountExport(idempotencyKey: newIdempotencyKey())).data!.data);

  @override
  Future<AccountExport> getExport(String id) => _guard(() async => (await _api.getAccountExport(id: id)).data!.data);

  @override
  Future<DeletionAccepted> deleteAccount() => _guard(
    () async => (await _api.deleteAccount(
      idempotencyKey: newIdempotencyKey(),
      deleteAccountRequest: DeleteAccountRequest(confirm: DeleteAccountRequestConfirmEnum.DELETE_MY_ACCOUNT),
    )).data!.data,
  );
}

class MockAccountRepository implements AccountRepository {
  @override
  Future<ExportAccepted> requestExport() async => ExportAccepted(exportId: 'mock-export', jobId: 'mock-export');

  @override
  Future<AccountExport> getExport(String id) async =>
      AccountExport(id: id, state: AccountExportStateEnum.completed, downloadUrl: null, expiresAt: null);

  @override
  Future<DeletionAccepted> deleteAccount() async =>
      DeletionAccepted(deletionRequestId: 'mock-deletion', state: DeletionAcceptedStateEnum.requested);
}
