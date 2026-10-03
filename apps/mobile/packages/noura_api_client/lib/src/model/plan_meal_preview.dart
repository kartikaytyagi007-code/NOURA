//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/meal_slot.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'plan_meal_preview.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlanMealPreview {
  /// Returns a new [PlanMealPreview] instance.
  PlanMealPreview({
    required this.planMealId,

    required this.slot,

    required this.title,
  });

  @JsonKey(name: r'plan_meal_id', required: true, includeIfNull: false)
  final String planMealId;

  @JsonKey(name: r'slot', required: true, includeIfNull: false)
  final MealSlot slot;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlanMealPreview &&
            runtimeType == other.runtimeType &&
            equals(
              [planMealId, slot, title],
              [other.planMealId, other.slot, other.title],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([planMealId, slot, title]);

  factory PlanMealPreview.fromJson(Map<String, dynamic> json) =>
      _$PlanMealPreviewFromJson(json);

  Map<String, dynamic> toJson() => _$PlanMealPreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
