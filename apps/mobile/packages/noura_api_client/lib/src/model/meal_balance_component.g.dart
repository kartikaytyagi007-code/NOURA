// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_balance_component.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealBalanceComponentCWProxy {
  MealBalanceComponent key(MealBalanceComponentKeyEnum key);

  MealBalanceComponent score(num? score);

  MealBalanceComponent maxScore(int maxScore);

  MealBalanceComponent evidence(Map<String, Object> evidence);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealBalanceComponent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealBalanceComponent(...).copyWith(id: 12, name: "My name")
  /// ````
  MealBalanceComponent call({
    MealBalanceComponentKeyEnum key,
    num? score,
    int maxScore,
    Map<String, Object> evidence,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealBalanceComponent.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealBalanceComponent.copyWith.fieldName(...)`
class _$MealBalanceComponentCWProxyImpl
    implements _$MealBalanceComponentCWProxy {
  const _$MealBalanceComponentCWProxyImpl(this._value);

  final MealBalanceComponent _value;

  @override
  MealBalanceComponent key(MealBalanceComponentKeyEnum key) => this(key: key);

  @override
  MealBalanceComponent score(num? score) => this(score: score);

  @override
  MealBalanceComponent maxScore(int maxScore) => this(maxScore: maxScore);

  @override
  MealBalanceComponent evidence(Map<String, Object> evidence) =>
      this(evidence: evidence);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealBalanceComponent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealBalanceComponent(...).copyWith(id: 12, name: "My name")
  /// ````
  MealBalanceComponent call({
    Object? key = const $CopyWithPlaceholder(),
    Object? score = const $CopyWithPlaceholder(),
    Object? maxScore = const $CopyWithPlaceholder(),
    Object? evidence = const $CopyWithPlaceholder(),
  }) {
    return MealBalanceComponent(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as MealBalanceComponentKeyEnum,
      score: score == const $CopyWithPlaceholder()
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as num?,
      maxScore: maxScore == const $CopyWithPlaceholder()
          ? _value.maxScore
          // ignore: cast_nullable_to_non_nullable
          : maxScore as int,
      evidence: evidence == const $CopyWithPlaceholder()
          ? _value.evidence
          // ignore: cast_nullable_to_non_nullable
          : evidence as Map<String, Object>,
    );
  }
}

extension $MealBalanceComponentCopyWith on MealBalanceComponent {
  /// Returns a callable class that can be used as follows: `instanceOfMealBalanceComponent.copyWith(...)` or like so:`instanceOfMealBalanceComponent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealBalanceComponentCWProxy get copyWith =>
      _$MealBalanceComponentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealBalanceComponent _$MealBalanceComponentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MealBalanceComponent', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['key', 'score', 'max_score', 'evidence'],
  );
  final val = MealBalanceComponent(
    key: $checkedConvert(
      'key',
      (v) => $enumDecode(_$MealBalanceComponentKeyEnumEnumMap, v),
    ),
    score: $checkedConvert('score', (v) => v as num?),
    maxScore: $checkedConvert('max_score', (v) => (v as num).toInt()),
    evidence: $checkedConvert(
      'evidence',
      (v) =>
          (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
}, fieldKeyMap: const {'maxScore': 'max_score'});

Map<String, dynamic> _$MealBalanceComponentToJson(
  MealBalanceComponent instance,
) => <String, dynamic>{
  'key': _$MealBalanceComponentKeyEnumEnumMap[instance.key]!,
  'score': instance.score,
  'max_score': instance.maxScore,
  'evidence': instance.evidence,
};

const _$MealBalanceComponentKeyEnumEnumMap = {
  MealBalanceComponentKeyEnum.protein: 'protein',
  MealBalanceComponentKeyEnum.fibre: 'fibre',
  MealBalanceComponentKeyEnum.vegetableFruit: 'vegetable_fruit',
  MealBalanceComponentKeyEnum.variety: 'variety',
};
