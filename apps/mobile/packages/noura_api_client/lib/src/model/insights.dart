//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/insight.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'insights.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Insights {
  /// Returns a new [Insights] instance.
  Insights({
    required this.periodStart,

    required this.periodEnd,

    required this.loggedMeals,

    required this.daysWithLogs,

    required this.insights,

    required this.focus,
  });

  @JsonKey(name: r'period_start', required: true, includeIfNull: false)
  final DateTime periodStart;

  @JsonKey(name: r'period_end', required: true, includeIfNull: false)
  final DateTime periodEnd;

  // minimum: 0
  @JsonKey(name: r'logged_meals', required: true, includeIfNull: false)
  final int loggedMeals;

  // minimum: 0
  // maximum: 7
  @JsonKey(name: r'days_with_logs', required: true, includeIfNull: false)
  final int daysWithLogs;

  @JsonKey(name: r'insights', required: true, includeIfNull: false)
  final List<Insight> insights;

  @JsonKey(name: r'focus', required: true, includeIfNull: true)
  final Insight? focus;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Insights &&
            runtimeType == other.runtimeType &&
            equals(
              [
                periodStart,
                periodEnd,
                loggedMeals,
                daysWithLogs,
                insights,
                focus,
              ],
              [
                other.periodStart,
                other.periodEnd,
                other.loggedMeals,
                other.daysWithLogs,
                other.insights,
                other.focus,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        periodStart,
        periodEnd,
        loggedMeals,
        daysWithLogs,
        insights,
        focus,
      ]);

  factory Insights.fromJson(Map<String, dynamic> json) =>
      _$InsightsFromJson(json);

  Map<String, dynamic> toJson() => _$InsightsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
