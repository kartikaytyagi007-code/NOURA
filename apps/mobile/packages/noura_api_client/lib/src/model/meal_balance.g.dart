// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_balance.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MealBalanceCWProxy {
  MealBalance score(int? score);

  MealBalance policyVersion(String policyVersion);

  MealBalance components(List<MealBalanceComponent> components);

  MealBalance missingDataMessage(String? missingDataMessage);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealBalance(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealBalance(...).copyWith(id: 12, name: "My name")
  /// ````
  MealBalance call({
    int? score,
    String policyVersion,
    List<MealBalanceComponent> components,
    String? missingDataMessage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMealBalance.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMealBalance.copyWith.fieldName(...)`
class _$MealBalanceCWProxyImpl implements _$MealBalanceCWProxy {
  const _$MealBalanceCWProxyImpl(this._value);

  final MealBalance _value;

  @override
  MealBalance score(int? score) => this(score: score);

  @override
  MealBalance policyVersion(String policyVersion) =>
      this(policyVersion: policyVersion);

  @override
  MealBalance components(List<MealBalanceComponent> components) =>
      this(components: components);

  @override
  MealBalance missingDataMessage(String? missingDataMessage) =>
      this(missingDataMessage: missingDataMessage);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MealBalance(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MealBalance(...).copyWith(id: 12, name: "My name")
  /// ````
  MealBalance call({
    Object? score = const $CopyWithPlaceholder(),
    Object? policyVersion = const $CopyWithPlaceholder(),
    Object? components = const $CopyWithPlaceholder(),
    Object? missingDataMessage = const $CopyWithPlaceholder(),
  }) {
    return MealBalance(
      score: score == const $CopyWithPlaceholder()
          ? _value.score
          // ignore: cast_nullable_to_non_nullable
          : score as int?,
      policyVersion: policyVersion == const $CopyWithPlaceholder()
          ? _value.policyVersion
          // ignore: cast_nullable_to_non_nullable
          : policyVersion as String,
      components: components == const $CopyWithPlaceholder()
          ? _value.components
          // ignore: cast_nullable_to_non_nullable
          : components as List<MealBalanceComponent>,
      missingDataMessage: missingDataMessage == const $CopyWithPlaceholder()
          ? _value.missingDataMessage
          // ignore: cast_nullable_to_non_nullable
          : missingDataMessage as String?,
    );
  }
}

extension $MealBalanceCopyWith on MealBalance {
  /// Returns a callable class that can be used as follows: `instanceOfMealBalance.copyWith(...)` or like so:`instanceOfMealBalance.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MealBalanceCWProxy get copyWith => _$MealBalanceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealBalance _$MealBalanceFromJson(Map<String, dynamic> json) => $checkedCreate(
  'MealBalance',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'score',
        'policy_version',
        'components',
        'missing_data_message',
      ],
    );
    final val = MealBalance(
      score: $checkedConvert('score', (v) => (v as num?)?.toInt()),
      policyVersion: $checkedConvert('policy_version', (v) => v as String),
      components: $checkedConvert(
        'components',
        (v) => (v as List<dynamic>)
            .map(
              (e) => MealBalanceComponent.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      ),
      missingDataMessage: $checkedConvert(
        'missing_data_message',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'policyVersion': 'policy_version',
    'missingDataMessage': 'missing_data_message',
  },
);

Map<String, dynamic> _$MealBalanceToJson(MealBalance instance) =>
    <String, dynamic>{
      'score': instance.score,
      'policy_version': instance.policyVersion,
      'components': instance.components.map((e) => e.toJson()).toList(),
      'missing_data_message': instance.missingDataMessage,
    };
