// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_options.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwapOptionsCWProxy {
  SwapOptions planMealId(String planMealId);

  SwapOptions revision(int revision);

  SwapOptions candidates(List<SwapCandidate> candidates);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwapOptions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwapOptions(...).copyWith(id: 12, name: "My name")
  /// ````
  SwapOptions call({
    String planMealId,
    int revision,
    List<SwapCandidate> candidates,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwapOptions.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwapOptions.copyWith.fieldName(...)`
class _$SwapOptionsCWProxyImpl implements _$SwapOptionsCWProxy {
  const _$SwapOptionsCWProxyImpl(this._value);

  final SwapOptions _value;

  @override
  SwapOptions planMealId(String planMealId) => this(planMealId: planMealId);

  @override
  SwapOptions revision(int revision) => this(revision: revision);

  @override
  SwapOptions candidates(List<SwapCandidate> candidates) =>
      this(candidates: candidates);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwapOptions(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwapOptions(...).copyWith(id: 12, name: "My name")
  /// ````
  SwapOptions call({
    Object? planMealId = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? candidates = const $CopyWithPlaceholder(),
  }) {
    return SwapOptions(
      planMealId: planMealId == const $CopyWithPlaceholder()
          ? _value.planMealId
          // ignore: cast_nullable_to_non_nullable
          : planMealId as String,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      candidates: candidates == const $CopyWithPlaceholder()
          ? _value.candidates
          // ignore: cast_nullable_to_non_nullable
          : candidates as List<SwapCandidate>,
    );
  }
}

extension $SwapOptionsCopyWith on SwapOptions {
  /// Returns a callable class that can be used as follows: `instanceOfSwapOptions.copyWith(...)` or like so:`instanceOfSwapOptions.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwapOptionsCWProxy get copyWith => _$SwapOptionsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwapOptions _$SwapOptionsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SwapOptions', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['plan_meal_id', 'revision', 'candidates'],
      );
      final val = SwapOptions(
        planMealId: $checkedConvert('plan_meal_id', (v) => v as String),
        revision: $checkedConvert('revision', (v) => (v as num).toInt()),
        candidates: $checkedConvert(
          'candidates',
          (v) => (v as List<dynamic>)
              .map((e) => SwapCandidate.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'planMealId': 'plan_meal_id'});

Map<String, dynamic> _$SwapOptionsToJson(SwapOptions instance) =>
    <String, dynamic>{
      'plan_meal_id': instance.planMealId,
      'revision': instance.revision,
      'candidates': instance.candidates.map((e) => e.toJson()).toList(),
    };
