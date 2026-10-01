// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_candidate.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SwapCandidateCWProxy {
  SwapCandidate candidateId(String candidateId);

  SwapCandidate recipe(RecipeRef recipe);

  SwapCandidate portions(List<PortionRef> portions);

  SwapCandidate nutrition(NutrientTotals nutrition);

  SwapCandidate dailyTotalsPreview(NutrientTotals dailyTotalsPreview);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwapCandidate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwapCandidate(...).copyWith(id: 12, name: "My name")
  /// ````
  SwapCandidate call({
    String candidateId,
    RecipeRef recipe,
    List<PortionRef> portions,
    NutrientTotals nutrition,
    NutrientTotals dailyTotalsPreview,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSwapCandidate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSwapCandidate.copyWith.fieldName(...)`
class _$SwapCandidateCWProxyImpl implements _$SwapCandidateCWProxy {
  const _$SwapCandidateCWProxyImpl(this._value);

  final SwapCandidate _value;

  @override
  SwapCandidate candidateId(String candidateId) =>
      this(candidateId: candidateId);

  @override
  SwapCandidate recipe(RecipeRef recipe) => this(recipe: recipe);

  @override
  SwapCandidate portions(List<PortionRef> portions) => this(portions: portions);

  @override
  SwapCandidate nutrition(NutrientTotals nutrition) =>
      this(nutrition: nutrition);

  @override
  SwapCandidate dailyTotalsPreview(NutrientTotals dailyTotalsPreview) =>
      this(dailyTotalsPreview: dailyTotalsPreview);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SwapCandidate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SwapCandidate(...).copyWith(id: 12, name: "My name")
  /// ````
  SwapCandidate call({
    Object? candidateId = const $CopyWithPlaceholder(),
    Object? recipe = const $CopyWithPlaceholder(),
    Object? portions = const $CopyWithPlaceholder(),
    Object? nutrition = const $CopyWithPlaceholder(),
    Object? dailyTotalsPreview = const $CopyWithPlaceholder(),
  }) {
    return SwapCandidate(
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
      dailyTotalsPreview: dailyTotalsPreview == const $CopyWithPlaceholder()
          ? _value.dailyTotalsPreview
          // ignore: cast_nullable_to_non_nullable
          : dailyTotalsPreview as NutrientTotals,
    );
  }
}

extension $SwapCandidateCopyWith on SwapCandidate {
  /// Returns a callable class that can be used as follows: `instanceOfSwapCandidate.copyWith(...)` or like so:`instanceOfSwapCandidate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SwapCandidateCWProxy get copyWith => _$SwapCandidateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwapCandidate _$SwapCandidateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SwapCandidate',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'candidate_id',
            'recipe',
            'portions',
            'nutrition',
            'daily_totals_preview',
          ],
        );
        final val = SwapCandidate(
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
          dailyTotalsPreview: $checkedConvert(
            'daily_totals_preview',
            (v) => NutrientTotals.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'candidateId': 'candidate_id',
        'dailyTotalsPreview': 'daily_totals_preview',
      },
    );

Map<String, dynamic> _$SwapCandidateToJson(SwapCandidate instance) =>
    <String, dynamic>{
      'candidate_id': instance.candidateId,
      'recipe': instance.recipe.toJson(),
      'portions': instance.portions.map((e) => e.toJson()).toList(),
      'nutrition': instance.nutrition.toJson(),
      'daily_totals_preview': instance.dailyTotalsPreview.toJson(),
    };
