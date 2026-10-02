// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InsightsCWProxy {
  Insights periodStart(DateTime periodStart);

  Insights periodEnd(DateTime periodEnd);

  Insights loggedMeals(int loggedMeals);

  Insights daysWithLogs(int daysWithLogs);

  Insights usableDays(int usableDays);

  Insights excludedDays(List<DateTime> excludedDays);

  Insights coverageUncertain(bool coverageUncertain);

  Insights insights(List<Insight> insights);

  Insights focus(Insight? focus);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Insights(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Insights(...).copyWith(id: 12, name: "My name")
  /// ````
  Insights call({
    DateTime periodStart,
    DateTime periodEnd,
    int loggedMeals,
    int daysWithLogs,
    int usableDays,
    List<DateTime> excludedDays,
    bool coverageUncertain,
    List<Insight> insights,
    Insight? focus,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInsights.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInsights.copyWith.fieldName(...)`
class _$InsightsCWProxyImpl implements _$InsightsCWProxy {
  const _$InsightsCWProxyImpl(this._value);

  final Insights _value;

  @override
  Insights periodStart(DateTime periodStart) => this(periodStart: periodStart);

  @override
  Insights periodEnd(DateTime periodEnd) => this(periodEnd: periodEnd);

  @override
  Insights loggedMeals(int loggedMeals) => this(loggedMeals: loggedMeals);

  @override
  Insights daysWithLogs(int daysWithLogs) => this(daysWithLogs: daysWithLogs);

  @override
  Insights usableDays(int usableDays) => this(usableDays: usableDays);

  @override
  Insights excludedDays(List<DateTime> excludedDays) =>
      this(excludedDays: excludedDays);

  @override
  Insights coverageUncertain(bool coverageUncertain) =>
      this(coverageUncertain: coverageUncertain);

  @override
  Insights insights(List<Insight> insights) => this(insights: insights);

  @override
  Insights focus(Insight? focus) => this(focus: focus);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Insights(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Insights(...).copyWith(id: 12, name: "My name")
  /// ````
  Insights call({
    Object? periodStart = const $CopyWithPlaceholder(),
    Object? periodEnd = const $CopyWithPlaceholder(),
    Object? loggedMeals = const $CopyWithPlaceholder(),
    Object? daysWithLogs = const $CopyWithPlaceholder(),
    Object? usableDays = const $CopyWithPlaceholder(),
    Object? excludedDays = const $CopyWithPlaceholder(),
    Object? coverageUncertain = const $CopyWithPlaceholder(),
    Object? insights = const $CopyWithPlaceholder(),
    Object? focus = const $CopyWithPlaceholder(),
  }) {
    return Insights(
      periodStart: periodStart == const $CopyWithPlaceholder()
          ? _value.periodStart
          // ignore: cast_nullable_to_non_nullable
          : periodStart as DateTime,
      periodEnd: periodEnd == const $CopyWithPlaceholder()
          ? _value.periodEnd
          // ignore: cast_nullable_to_non_nullable
          : periodEnd as DateTime,
      loggedMeals: loggedMeals == const $CopyWithPlaceholder()
          ? _value.loggedMeals
          // ignore: cast_nullable_to_non_nullable
          : loggedMeals as int,
      daysWithLogs: daysWithLogs == const $CopyWithPlaceholder()
          ? _value.daysWithLogs
          // ignore: cast_nullable_to_non_nullable
          : daysWithLogs as int,
      usableDays: usableDays == const $CopyWithPlaceholder()
          ? _value.usableDays
          // ignore: cast_nullable_to_non_nullable
          : usableDays as int,
      excludedDays: excludedDays == const $CopyWithPlaceholder()
          ? _value.excludedDays
          // ignore: cast_nullable_to_non_nullable
          : excludedDays as List<DateTime>,
      coverageUncertain: coverageUncertain == const $CopyWithPlaceholder()
          ? _value.coverageUncertain
          // ignore: cast_nullable_to_non_nullable
          : coverageUncertain as bool,
      insights: insights == const $CopyWithPlaceholder()
          ? _value.insights
          // ignore: cast_nullable_to_non_nullable
          : insights as List<Insight>,
      focus: focus == const $CopyWithPlaceholder()
          ? _value.focus
          // ignore: cast_nullable_to_non_nullable
          : focus as Insight?,
    );
  }
}

extension $InsightsCopyWith on Insights {
  /// Returns a callable class that can be used as follows: `instanceOfInsights.copyWith(...)` or like so:`instanceOfInsights.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InsightsCWProxy get copyWith => _$InsightsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Insights _$InsightsFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Insights',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'period_start',
        'period_end',
        'logged_meals',
        'days_with_logs',
        'usable_days',
        'excluded_days',
        'coverage_uncertain',
        'insights',
        'focus',
      ],
    );
    final val = Insights(
      periodStart: $checkedConvert(
        'period_start',
        (v) => DateTime.parse(v as String),
      ),
      periodEnd: $checkedConvert(
        'period_end',
        (v) => DateTime.parse(v as String),
      ),
      loggedMeals: $checkedConvert('logged_meals', (v) => (v as num).toInt()),
      daysWithLogs: $checkedConvert(
        'days_with_logs',
        (v) => (v as num).toInt(),
      ),
      usableDays: $checkedConvert('usable_days', (v) => (v as num).toInt()),
      excludedDays: $checkedConvert(
        'excluded_days',
        (v) => (v as List<dynamic>)
            .map((e) => DateTime.parse(e as String))
            .toList(),
      ),
      coverageUncertain: $checkedConvert(
        'coverage_uncertain',
        (v) => v as bool,
      ),
      insights: $checkedConvert(
        'insights',
        (v) => (v as List<dynamic>)
            .map((e) => Insight.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      focus: $checkedConvert(
        'focus',
        (v) => v == null ? null : Insight.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'periodStart': 'period_start',
    'periodEnd': 'period_end',
    'loggedMeals': 'logged_meals',
    'daysWithLogs': 'days_with_logs',
    'usableDays': 'usable_days',
    'excludedDays': 'excluded_days',
    'coverageUncertain': 'coverage_uncertain',
  },
);

Map<String, dynamic> _$InsightsToJson(Insights instance) => <String, dynamic>{
  'period_start': instance.periodStart.toIso8601String(),
  'period_end': instance.periodEnd.toIso8601String(),
  'logged_meals': instance.loggedMeals,
  'days_with_logs': instance.daysWithLogs,
  'usable_days': instance.usableDays,
  'excluded_days': instance.excludedDays
      .map((e) => e.toIso8601String())
      .toList(),
  'coverage_uncertain': instance.coverageUncertain,
  'insights': instance.insights.map((e) => e.toJson()).toList(),
  'focus': instance.focus?.toJson(),
};
