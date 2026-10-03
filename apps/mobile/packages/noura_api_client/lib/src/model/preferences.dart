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

part 'preferences.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Preferences {
  /// Returns a new [Preferences] instance.
  Preferences({
    required this.dietType,

    required this.allergyIds,

    required this.exclusionIds,

    required this.dislikes,

    required this.cuisines,

    required this.budgetBand,

    required this.cookingTime,

    required this.mealsPerDay,

    required this.revision,
  });

  @JsonKey(name: r'diet_type', required: true, includeIfNull: true)
  final DietType? dietType;

  @JsonKey(name: r'allergy_ids', required: true, includeIfNull: false)
  final List<String> allergyIds;

  @JsonKey(name: r'exclusion_ids', required: true, includeIfNull: false)
  final List<String> exclusionIds;

  @JsonKey(name: r'dislikes', required: true, includeIfNull: false)
  final List<String> dislikes;

  @JsonKey(name: r'cuisines', required: true, includeIfNull: false)
  final List<String> cuisines;

  @JsonKey(name: r'budget_band', required: true, includeIfNull: true)
  final BudgetBand? budgetBand;

  @JsonKey(name: r'cooking_time', required: true, includeIfNull: true)
  final CookingTime? cookingTime;

  // minimum: 1
  // maximum: 8
  @JsonKey(name: r'meals_per_day', required: true, includeIfNull: true)
  final int? mealsPerDay;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Preferences &&
            runtimeType == other.runtimeType &&
            equals(
              [
                dietType,
                allergyIds,
                exclusionIds,
                dislikes,
                cuisines,
                budgetBand,
                cookingTime,
                mealsPerDay,
                revision,
              ],
              [
                other.dietType,
                other.allergyIds,
                other.exclusionIds,
                other.dislikes,
                other.cuisines,
                other.budgetBand,
                other.cookingTime,
                other.mealsPerDay,
                other.revision,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        dietType,
        allergyIds,
        exclusionIds,
        dislikes,
        cuisines,
        budgetBand,
        cookingTime,
        mealsPerDay,
        revision,
      ]);

  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$PreferencesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
