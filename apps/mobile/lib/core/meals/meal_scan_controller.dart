import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';
import '../providers.dart' show mealScanRepositoryProvider;
import 'meal_scan_repository.dart';
import 'meal_scan_state.dart';

/// Terminal scan statuses that stop polling (blueprint §8 state machine).
const _terminalStatuses = {
  MealScanStatus.needsConfirmation,
  MealScanStatus.ready,
  MealScanStatus.failed,
  MealScanStatus.cancelled,
  MealScanStatus.expired,
};

/// Drives the capture → upload → processing → review → correction → save flow for one scan.
/// Mirrors [DietController]'s conventions (repository-only access, server is the only source of
/// nutrition), but models an explicit multi-step flow instead of a single resource.
class MealScanController extends Notifier<MealScanFlowState> {
  @override
  MealScanFlowState build() => const MealScanIdle();

  MealScanRepository get _repository => ref.read(mealScanRepositoryProvider);

  /// Resets to the capture step, discarding any in-progress or finished scan.
  void reset() => state = const MealScanIdle();

  /// Uploads the captured/picked photo and starts recognition, then polls until the scan reaches a
  /// terminal status. Never fabricates a result: a provider failure or non-food photo surfaces as
  /// [MealScanFailed] with the server's own safe message.
  Future<void> captureAndAnalyze(Uint8List bytes, {required ImageMime mime}) async {
    state = MealScanUploading(bytes);
    try {
      final mediaId = await _repository.uploadMealImage(bytes, mime: mime);
      final accepted = await _repository.startScan(mediaId);
      state = MealScanProcessing(accepted.scanId);
      await _pollUntilTerminal(accepted.scanId);
    } on ApiFailure catch (error) {
      state = MealScanFailed(message: error.message, retryable: error.retryable || error.isOffline);
    }
  }

  Future<void> _pollUntilTerminal(String scanId) async {
    const maxAttempts = 30;
    const interval = Duration(seconds: 2);
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final scan = await _repository.getScan(scanId);
      if (_terminalStatuses.contains(scan.status)) {
        _applyTerminalScan(scan);
        return;
      }
      await Future<void>.delayed(interval);
    }
    state = const MealScanFailed(
      message: "This is taking longer than expected. You can check back from the diary shortly.",
      retryable: true,
    );
  }

  void _applyTerminalScan(MealScan scan) {
    switch (scan.status) {
      case MealScanStatus.needsConfirmation:
      case MealScanStatus.ready:
        final recognition = scan.recognition;
        if (recognition == null) {
          state = const MealScanFailed(message: 'The scan finished without any items to review.');
          return;
        }
        if (!recognition.imageIsFood) {
          state = const MealScanFailed(
            message: "We couldn't find food in that photo. Try again with the meal clearly in frame.",
            retryable: true,
            notFood: true,
          );
          return;
        }
        state = MealScanReviewing(
          scanId: scan.id,
          revision: scan.revision,
          items: [for (final item in recognition.items) ReviewItem.fromRecognition(item)],
          clarification: recognition.clarification,
        );
      case MealScanStatus.failed:
        final error = scan.error;
        state = MealScanFailed(
          message: error?.message ?? 'The scan could not be completed.',
          notFood: error?.code == 'not_food',
        );
      case MealScanStatus.cancelled:
      case MealScanStatus.expired:
        state = const MealScanFailed(message: 'This scan is no longer available. Please try again.', retryable: true);
      case MealScanStatus.awaitingUpload:
      case MealScanStatus.queued:
      case MealScanStatus.recognizing:
        state = MealScanProcessing(scan.id);
    }
  }

  /// Edits a reviewed item's label and/or grams in place.
  void updateItem(String temporaryId, {String? label, num? grams}) {
    final current = state;
    if (current is! MealScanReviewing) return;
    state = current.copyWithItems([
      for (final item in current.items)
        if (item.temporaryId == temporaryId) item.copyWith(label: label, grams: grams) else item,
    ]);
  }

  /// Marks an item removed (it is excluded from confirmation, not deleted from the list, so the
  /// user can see what they chose to drop).
  void removeItem(String temporaryId) {
    final current = state;
    if (current is! MealScanReviewing) return;
    state = current.copyWithItems([
      for (final item in current.items)
        if (item.temporaryId == temporaryId) item.copyWith(removed: true) else item,
    ]);
  }

  void addManualItem(String label) {
    final current = state;
    if (current is! MealScanReviewing) return;
    final id = 'manual-${DateTime.now().microsecondsSinceEpoch}';
    state = current.copyWithItems([...current.items, ReviewItem(temporaryId: id, label: label, grams: null)]);
  }

  /// Confirms the (edited) items and moves to the Meal Balance / Fix-My-Plate step (blueprint §8:
  /// confirm → Meal Balance → Fix My Plate → log). Nothing is logged yet. A stale revision surfaces
  /// as [ApiFailure] for the caller, and the review step (with edits intact) is restored so the user
  /// can reload and retry, matching the M2/M3 revision-conflict convention.
  Future<void> confirmItems() async {
    final current = state;
    if (current is! MealScanReviewing) {
      throw StateError('confirmItems called outside the review step');
    }
    final items = [
      for (final item in current.items)
        if (!item.removed) item.toInput(),
    ];
    state = const MealScanSaving();
    try {
      final analysis = await _repository.confirmItems(
        scanId: current.scanId,
        expectedRevision: current.revision,
        items: items,
      );
      state = MealScanAnalyzed(
        scanId: current.scanId,
        revision: analysis.revision,
        analysis: analysis,
        confirmedItems: items,
      );
    } on ApiFailure {
      state = current;
      rethrow;
    }
  }

  /// Returns to the review/correction step from the analyzed step, so the user can fix a
  /// mis-recognized item or portion rather than only accepting or rejecting the whole meal (M5
  /// ticket's "user-correction state": it reuses M4's correction flow instead of duplicating it).
  void backToReview() {
    final current = state;
    if (current is! MealScanAnalyzed) return;
    state = MealScanReviewing(
      scanId: current.scanId,
      revision: current.revision,
      items: [
        for (final input in current.confirmedItems)
          ReviewItem(temporaryId: input.temporaryId ?? input.label, label: input.label, grams: input.grams),
      ],
    );
  }

  /// Logs the meal analyzed in [MealScanAnalyzed] (as-is, or after the user applied Fix-My-Plate
  /// changes by editing items and re-confirming). Returns the saved log on success.
  Future<MealLog> logConfirmedMeal({
    required DateTime consumedAt,
    required String timezone,
    required MealSlot slot,
  }) async {
    final current = state;
    if (current is! MealScanAnalyzed) {
      throw StateError('logConfirmedMeal called outside the analyzed step');
    }
    state = const MealScanSaving();
    try {
      final log = await _repository.logMeal(
        consumedAt: consumedAt,
        timezone: timezone,
        slot: slot,
        scanId: current.scanId,
        items: current.confirmedItems,
      );
      state = MealScanSaved(log);
      return log;
    } on ApiFailure {
      state = current;
      rethrow;
    }
  }
}

final mealScanControllerProvider = NotifierProvider<MealScanController, MealScanFlowState>(MealScanController.new);
