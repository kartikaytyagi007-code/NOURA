//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/meal_slot.dart';
import 'package:noura_api_client/src/model/next_meal_option.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'next_meal.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NextMeal {
  /// Returns a new [NextMeal] instance.
  NextMeal({
    required this.date,

    required this.slot,

    required this.loggedMeals,

    required this.limitedContext,

    required this.explanation,

    required this.options,
  });

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'slot', required: true, includeIfNull: false)
  final MealSlot slot;

  // minimum: 0
  @JsonKey(name: r'logged_meals', required: true, includeIfNull: false)
  final int loggedMeals;

  @JsonKey(name: r'limited_context', required: true, includeIfNull: false)
  final bool limitedContext;

  @JsonKey(name: r'explanation', required: true, includeIfNull: true)
  final String? explanation;

  @JsonKey(name: r'options', required: true, includeIfNull: false)
  final List<NextMealOption> options;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NextMeal &&
            runtimeType == other.runtimeType &&
            equals(
              [date, slot, loggedMeals, limitedContext, explanation, options],
              [
                other.date,
                other.slot,
                other.loggedMeals,
                other.limitedContext,
                other.explanation,
                other.options,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        date,
        slot,
        loggedMeals,
        limitedContext,
        explanation,
        options,
      ]);

  factory NextMeal.fromJson(Map<String, dynamic> json) =>
      _$NextMealFromJson(json);

  Map<String, dynamic> toJson() => _$NextMealToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
