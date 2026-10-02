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

    required this.usableDays,

    required this.excludedDays,

    required this.coverageUncertain,

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

  /// Days with logged meals AND complete nutrition coverage; the denominator of any average shown.
  // minimum: 0
  // maximum: 7
  @JsonKey(name: r'usable_days', required: true, includeIfNull: false)
  final int usableDays;

  /// Dates left out of the average because nothing was logged or coverage was incomplete.
  @JsonKey(name: r'excluded_days', required: true, includeIfNull: false)
  final List<DateTime> excludedDays;

  /// True when at least one day in the window was excluded from the average.
  @JsonKey(name: r'coverage_uncertain', required: true, includeIfNull: false)
  final bool coverageUncertain;

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
                usableDays,
                excludedDays,
                coverageUncertain,
                insights,
                focus,
              ],
              [
                other.periodStart,
                other.periodEnd,
                other.loggedMeals,
                other.daysWithLogs,
                other.usableDays,
                other.excludedDays,
                other.coverageUncertain,
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
        usableDays,
        excludedDays,
        coverageUncertain,
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
