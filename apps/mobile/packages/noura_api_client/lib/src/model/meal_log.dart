//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/meal_slot.dart';
import 'package:noura_api_client/src/model/meal_balance.dart';
import 'package:noura_api_client/src/model/analyzed_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'meal_log.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealLog {
  /// Returns a new [MealLog] instance.
  MealLog({
    required this.id,

    required this.clientId,

    required this.consumedAt,

    required this.localDate,

    required this.slot,

    required this.scanId,

    required this.planMealId,

    required this.items,

    required this.totals,

    required this.mealBalance,

    required this.revision,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'client_id', required: true, includeIfNull: false)
  final String clientId;

  @JsonKey(name: r'consumed_at', required: true, includeIfNull: false)
  final DateTime consumedAt;

  @JsonKey(name: r'local_date', required: true, includeIfNull: false)
  final DateTime localDate;

  @JsonKey(name: r'slot', required: true, includeIfNull: false)
  final MealSlot slot;

  @JsonKey(name: r'scan_id', required: true, includeIfNull: true)
  final String? scanId;

  @JsonKey(name: r'plan_meal_id', required: true, includeIfNull: true)
  final String? planMealId;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<AnalyzedItem> items;

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final NutrientTotals totals;

  @JsonKey(name: r'meal_balance', required: true, includeIfNull: true)
  final MealBalance? mealBalance;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MealLog &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                clientId,
                consumedAt,
                localDate,
                slot,
                scanId,
                planMealId,
                items,
                totals,
                mealBalance,
                revision,
              ],
              [
                other.id,
                other.clientId,
                other.consumedAt,
                other.localDate,
                other.slot,
                other.scanId,
                other.planMealId,
                other.items,
                other.totals,
                other.mealBalance,
                other.revision,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        clientId,
        consumedAt,
        localDate,
        slot,
        scanId,
        planMealId,
        items,
        totals,
        mealBalance,
        revision,
      ]);

  factory MealLog.fromJson(Map<String, dynamic> json) =>
      _$MealLogFromJson(json);

  Map<String, dynamic> toJson() => _$MealLogToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
