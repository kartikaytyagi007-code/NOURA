//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/cooking_time.dart';
import 'package:noura_api_client/src/model/diet_type.dart';
import 'package:noura_api_client/src/model/budget_band.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'preferences_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreferencesInput {
  /// Returns a new [PreferencesInput] instance.
  PreferencesInput({
    required this.expectedRevision,

    required this.dietType,

    required this.allergyIds,

    required this.exclusionIds,

    this.dislikes,

    required this.cuisines,

    required this.budgetBand,

    required this.cookingTime,

    required this.mealsPerDay,
  });

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'diet_type', required: true, includeIfNull: false)
  final DietType dietType;

  @JsonKey(name: r'allergy_ids', required: true, includeIfNull: false)
  final Set<String> allergyIds;

  @JsonKey(name: r'exclusion_ids', required: true, includeIfNull: false)
  final Set<String> exclusionIds;

  @JsonKey(name: r'dislikes', required: false, includeIfNull: false)
  final Set<String>? dislikes;

  @JsonKey(name: r'cuisines', required: true, includeIfNull: false)
  final Set<String> cuisines;

  @JsonKey(name: r'budget_band', required: true, includeIfNull: false)
  final BudgetBand budgetBand;

  @JsonKey(name: r'cooking_time', required: true, includeIfNull: false)
  final CookingTime cookingTime;

  // minimum: 1
  // maximum: 8
  @JsonKey(name: r'meals_per_day', required: true, includeIfNull: false)
  final int mealsPerDay;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PreferencesInput &&
            runtimeType == other.runtimeType &&
            equals(
              [
                expectedRevision,
                dietType,
                allergyIds,
                exclusionIds,
                dislikes,
                cuisines,
                budgetBand,
                cookingTime,
                mealsPerDay,
              ],
              [
                other.expectedRevision,
                other.dietType,
                other.allergyIds,
                other.exclusionIds,
                other.dislikes,
                other.cuisines,
                other.budgetBand,
                other.cookingTime,
                other.mealsPerDay,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        expectedRevision,
        dietType,
        allergyIds,
        exclusionIds,
        dislikes,
        cuisines,
        budgetBand,
        cookingTime,
        mealsPerDay,
      ]);

  factory PreferencesInput.fromJson(Map<String, dynamic> json) =>
      _$PreferencesInputFromJson(json);

  Map<String, dynamic> toJson() => _$PreferencesInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
