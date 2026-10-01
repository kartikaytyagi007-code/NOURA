// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_card.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachCardCWProxy {
  CoachCard type(CoachCardTypeEnum type);

  CoachCard title(String title);

  CoachCard refId(String? refId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachCard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachCard(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachCard call({CoachCardTypeEnum type, String title, String? refId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachCard.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachCard.copyWith.fieldName(...)`
class _$CoachCardCWProxyImpl implements _$CoachCardCWProxy {
  const _$CoachCardCWProxyImpl(this._value);

  final CoachCard _value;

  @override
  CoachCard type(CoachCardTypeEnum type) => this(type: type);

  @override
  CoachCard title(String title) => this(title: title);

  @override
  CoachCard refId(String? refId) => this(refId: refId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachCard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachCard(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachCard call({
    Object? type = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? refId = const $CopyWithPlaceholder(),
  }) {
    return CoachCard(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as CoachCardTypeEnum,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      refId: refId == const $CopyWithPlaceholder()
          ? _value.refId
          // ignore: cast_nullable_to_non_nullable
          : refId as String?,
    );
  }
}

extension $CoachCardCopyWith on CoachCard {
  /// Returns a callable class that can be used as follows: `instanceOfCoachCard.copyWith(...)` or like so:`instanceOfCoachCard.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachCardCWProxy get copyWith => _$CoachCardCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachCard _$CoachCardFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CoachCard', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['type', 'title', 'ref_id']);
      final val = CoachCard(
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$CoachCardTypeEnumEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String),
        refId: $checkedConvert('ref_id', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'refId': 'ref_id'});

Map<String, dynamic> _$CoachCardToJson(CoachCard instance) => <String, dynamic>{
  'type': _$CoachCardTypeEnumEnumMap[instance.type]!,
  'title': instance.title,
  'ref_id': instance.refId,
};

const _$CoachCardTypeEnumEnumMap = {
  CoachCardTypeEnum.meal: 'meal',
  CoachCardTypeEnum.workout: 'workout',
  CoachCardTypeEnum.insight: 'insight',
};
