import 'package:flutter/foundation.dart';
import 'package:noura_api_client/noura_api_client.dart';

import '../api/api_failure.dart';

/// One editable row in the review/correction step. Starts from a [RecognitionItem] (or a manual
/// add) and is converted to a [ConfirmedItemInput] when the user confirms. Nutrition is never
/// computed on the client: it only ever reflects what the server returned in [analyzedNutrients].
@immutable
class ReviewItem {
  const ReviewItem({
    required this.temporaryId,
    required this.label,
    required this.grams,
    this.confidenceBand,
    this.needsConfirmation = false,
    this.catalogCandidates = const [],
    this.analyzedNutrients,
    this.uncertainty,
    this.removed = false,
  });

  final String temporaryId;
  final String label;
  final num? grams;
  final RecognitionItemConfidenceBandEnum? confidenceBand;
  final bool needsConfirmation;
  final List<String> catalogCandidates;
  final Nutrients? analyzedNutrients;
  final Uncertainty? uncertainty;
  final bool removed;

  ReviewItem copyWith({
    String? label,
    num? grams,
    bool? removed,
    Nutrients? analyzedNutrients,
    Uncertainty? uncertainty,
  }) {
    return ReviewItem(
      temporaryId: temporaryId,
      label: label ?? this.label,
      grams: grams ?? this.grams,
      confidenceBand: confidenceBand,
      needsConfirmation: needsConfirmation,
      catalogCandidates: catalogCandidates,
      analyzedNutrients: analyzedNutrients ?? this.analyzedNutrients,
      uncertainty: uncertainty ?? this.uncertainty,
      removed: removed ?? this.removed,
    );
  }

  ConfirmedItemInput toInput() => ConfirmedItemInput(temporaryId: temporaryId, label: label, grams: grams);

  static ReviewItem fromRecognition(RecognitionItem item) => ReviewItem(
    temporaryId: item.temporaryId,
    label: item.label,
    grams: item.estimatedGrams == null ? null : (item.estimatedGrams!.min + item.estimatedGrams!.max) / 2,
    confidenceBand: item.confidenceBand,
    needsConfirmation: item.needsConfirmation,
    catalogCandidates: item.catalogCandidates,
  );
}

/// The meal-scan flow's state machine (blueprint §8: capture → upload → processing → review →
/// correction → save). Each variant maps to exactly one screen state; [MealScanController] is the
/// only writer.
@immutable
sealed class MealScanFlowState {
  const MealScanFlowState();
}

class MealScanIdle extends MealScanFlowState {
  const MealScanIdle();
}

class MealScanUploading extends MealScanFlowState {
  const MealScanUploading(this.imageBytes);
  final Uint8List imageBytes;
}

class MealScanProcessing extends MealScanFlowState {
  const MealScanProcessing(this.scanId);
  final String scanId;
}

/// Recognition finished and the user is reviewing/correcting items before confirming.
class MealScanReviewing extends MealScanFlowState {
  const MealScanReviewing({required this.scanId, required this.revision, required this.items, this.clarification});
  final String scanId;
  final int revision;
  final List<ReviewItem> items;
  final String? clarification;

  MealScanReviewing copyWithItems(List<ReviewItem> items) =>
      MealScanReviewing(scanId: scanId, revision: revision, items: items, clarification: clarification);
}

/// Items are confirmed and calculated (nutrition + Meal Balance); the user reviews the result and
/// can open "Fix My Plate", go back to correct items, or log the meal as-is (blueprint §8 step 7,
/// M5). [confirmedItems] is kept so the same items can be re-submitted to [MealScanController.logConfirmedMeal]
/// without the user re-entering anything.
class MealScanAnalyzed extends MealScanFlowState {
  const MealScanAnalyzed({
    required this.scanId,
    required this.revision,
    required this.analysis,
    required this.confirmedItems,
  });
  final String scanId;
  final int revision;
  final MealAnalysis analysis;
  final List<ConfirmedItemInput> confirmedItems;
}

class MealScanSaving extends MealScanFlowState {
  const MealScanSaving();
}

class MealScanSaved extends MealScanFlowState {
  const MealScanSaved(this.log);
  final MealLog log;
}

/// The photo was not food, or the provider could not be reached, or recognition otherwise failed
/// without anything to review. [retryable] mirrors [ApiFailure.retryable] / honest failure codes
/// from `meal_scans.error` (never a generic crash message).
class MealScanFailed extends MealScanFlowState {
  const MealScanFailed({required this.message, this.retryable = true, this.notFood = false});
  final String message;
  final bool retryable;
  final bool notFood;
}
