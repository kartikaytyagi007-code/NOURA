//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/meal_log.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'meal_diary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MealDiary {
  /// Returns a new [MealDiary] instance.
  MealDiary({required this.date, required this.logs, required this.totals});

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'logs', required: true, includeIfNull: false)
  final List<MealLog> logs;

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final NutrientTotals totals;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MealDiary &&
            runtimeType == other.runtimeType &&
            equals(
              [date, logs, totals],
              [other.date, other.logs, other.totals],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([date, logs, totals]);

  factory MealDiary.fromJson(Map<String, dynamic> json) =>
      _$MealDiaryFromJson(json);

  Map<String, dynamic> toJson() => _$MealDiaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
