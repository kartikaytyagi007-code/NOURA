// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adherence_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdherenceSummaryCWProxy {
  AdherenceSummary planActive(bool planActive);

  AdherenceSummary planned(int? planned);

  AdherenceSummary logged(int? logged);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdherenceSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdherenceSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AdherenceSummary call({bool planActive, int? planned, int? logged});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdherenceSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdherenceSummary.copyWith.fieldName(...)`
class _$AdherenceSummaryCWProxyImpl implements _$AdherenceSummaryCWProxy {
  const _$AdherenceSummaryCWProxyImpl(this._value);

  final AdherenceSummary _value;

  @override
  AdherenceSummary planActive(bool planActive) => this(planActive: planActive);

  @override
  AdherenceSummary planned(int? planned) => this(planned: planned);

  @override
  AdherenceSummary logged(int? logged) => this(logged: logged);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdherenceSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdherenceSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  AdherenceSummary call({
    Object? planActive = const $CopyWithPlaceholder(),
    Object? planned = const $CopyWithPlaceholder(),
    Object? logged = const $CopyWithPlaceholder(),
  }) {
    return AdherenceSummary(
      planActive: planActive == const $CopyWithPlaceholder()
          ? _value.planActive
          // ignore: cast_nullable_to_non_nullable
          : planActive as bool,
      planned: planned == const $CopyWithPlaceholder()
          ? _value.planned
          // ignore: cast_nullable_to_non_nullable
          : planned as int?,
      logged: logged == const $CopyWithPlaceholder()
          ? _value.logged
          // ignore: cast_nullable_to_non_nullable
          : logged as int?,
    );
  }
}

extension $AdherenceSummaryCopyWith on AdherenceSummary {
  /// Returns a callable class that can be used as follows: `instanceOfAdherenceSummary.copyWith(...)` or like so:`instanceOfAdherenceSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdherenceSummaryCWProxy get copyWith => _$AdherenceSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdherenceSummary _$AdherenceSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdherenceSummary', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['plan_active', 'planned', 'logged'],
      );
      final val = AdherenceSummary(
        planActive: $checkedConvert('plan_active', (v) => v as bool),
        planned: $checkedConvert('planned', (v) => (v as num?)?.toInt()),
        logged: $checkedConvert('logged', (v) => (v as num?)?.toInt()),
      );
      return val;
    }, fieldKeyMap: const {'planActive': 'plan_active'});

Map<String, dynamic> _$AdherenceSummaryToJson(AdherenceSummary instance) =>
    <String, dynamic>{
      'plan_active': instance.planActive,
      'planned': instance.planned,
      'logged': instance.logged,
    };
