// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_meal_option.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NextMealOptionCWProxy {
  NextMealOption source_(NextMealSource source_);

  NextMealOption planMealId(String? planMealId);

  NextMealOption planMealRevision(int? planMealRevision);

  NextMealOption candidateId(String candidateId);

  NextMealOption recipe(RecipeRef recipe);

  NextMealOption portions(List<PortionRef> portions);

  NextMealOption nutrition(NutrientTotals nutrition);

  NextMealOption reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealOption(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealOption(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealOption call({
    NextMealSource source_,
    String? planMealId,
    int? planMealRevision,
    String candidateId,
    RecipeRef recipe,
    List<PortionRef> portions,
    NutrientTotals nutrition,
    String reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNextMealOption.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNextMealOption.copyWith.fieldName(...)`
class _$NextMealOptionCWProxyImpl implements _$NextMealOptionCWProxy {
  const _$NextMealOptionCWProxyImpl(this._value);

  final NextMealOption _value;

  @override
  NextMealOption source_(NextMealSource source_) => this(source_: source_);

  @override
  NextMealOption planMealId(String? planMealId) => this(planMealId: planMealId);

  @override
  NextMealOption planMealRevision(int? planMealRevision) =>
      this(planMealRevision: planMealRevision);

  @override
  NextMealOption candidateId(String candidateId) =>
      this(candidateId: candidateId);

  @override
  NextMealOption recipe(RecipeRef recipe) => this(recipe: recipe);

  @override
  NextMealOption portions(List<PortionRef> portions) =>
      this(portions: portions);

  @override
  NextMealOption nutrition(NutrientTotals nutrition) =>
      this(nutrition: nutrition);

  @override
  NextMealOption reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NextMealOption(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NextMealOption(...).copyWith(id: 12, name: "My name")
  /// ````
  NextMealOption call({
    Object? source_ = const $CopyWithPlaceholder(),
    Object? planMealId = const $CopyWithPlaceholder(),
    Object? planMealRevision = const $CopyWithPlaceholder(),
    Object? candidateId = const $CopyWithPlaceholder(),
    Object? recipe = const $CopyWithPlaceholder(),
    Object? portions = const $CopyWithPlaceholder(),
    Object? nutrition = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return NextMealOption(
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as NextMealSource,
      planMealId: planMealId == const $CopyWithPlaceholder()
          ? _value.planMealId
          // ignore: cast_nullable_to_non_nullable
          : planMealId as String?,
      planMealRevision: planMealRevision == const $CopyWithPlaceholder()
          ? _value.planMealRevision
          // ignore: cast_nullable_to_non_nullable
          : planMealRevision as int?,
      candidateId: candidateId == const $CopyWithPlaceholder()
          ? _value.candidateId
          // ignore: cast_nullable_to_non_nullable
          : candidateId as String,
      recipe: recipe == const $CopyWithPlaceholder()
          ? _value.recipe
          // ignore: cast_nullable_to_non_nullable
          : recipe as RecipeRef,
      portions: portions == const $CopyWithPlaceholder()
          ? _value.portions
          // ignore: cast_nullable_to_non_nullable
          : portions as List<PortionRef>,
      nutrition: nutrition == const $CopyWithPlaceholder()
          ? _value.nutrition
          // ignore: cast_nullable_to_non_nullable
          : nutrition as NutrientTotals,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $NextMealOptionCopyWith on NextMealOption {
  /// Returns a callable class that can be used as follows: `instanceOfNextMealOption.copyWith(...)` or like so:`instanceOfNextMealOption.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NextMealOptionCWProxy get copyWith => _$NextMealOptionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NextMealOption _$NextMealOptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'NextMealOption',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'source',
            'plan_meal_id',
            'plan_meal_revision',
            'candidate_id',
            'recipe',
            'portions',
            'nutrition',
            'reason',
          ],
        );
        final val = NextMealOption(
          source_: $checkedConvert(
            'source',
            (v) => $enumDecode(_$NextMealSourceEnumMap, v),
          ),
          planMealId: $checkedConvert('plan_meal_id', (v) => v as String?),
          planMealRevision: $checkedConvert(
            'plan_meal_revision',
            (v) => (v as num?)?.toInt(),
          ),
          candidateId: $checkedConvert('candidate_id', (v) => v as String),
          recipe: $checkedConvert(
            'recipe',
            (v) => RecipeRef.fromJson(v as Map<String, dynamic>),
          ),
          portions: $checkedConvert(
            'portions',
            (v) => (v as List<dynamic>)
                .map((e) => PortionRef.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          nutrition: $checkedConvert(
            'nutrition',
            (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
          ),
          reason: $checkedConvert('reason', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'source_': 'source',
        'planMealId': 'plan_meal_id',
        'planMealRevision': 'plan_meal_revision',
        'candidateId': 'candidate_id',
      },
    );

Map<String, dynamic> _$NextMealOptionToJson(NextMealOption instance) =>
    <String, dynamic>{
      'source': _$NextMealSourceEnumMap[instance.source_]!,
      'plan_meal_id': instance.planMealId,
      'plan_meal_revision': instance.planMealRevision,
      'candidate_id': instance.candidateId,
      'recipe': instance.recipe.toJson(),
      'portions': instance.portions.map((e) => e.toJson()).toList(),
      'nutrition': instance.nutrition.toJson(),
      'reason': instance.reason,
    };

const _$NextMealSourceEnumMap = {
  NextMealSource.plan: 'plan',
  NextMealSource.catalog: 'catalog',
};
