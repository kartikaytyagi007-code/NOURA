// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_message_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachMessageListCWProxy {
  CoachMessageList items(List<CoachMessage> items);

  CoachMessageList nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessageList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessageList(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessageList call({List<CoachMessage> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachMessageList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachMessageList.copyWith.fieldName(...)`
class _$CoachMessageListCWProxyImpl implements _$CoachMessageListCWProxy {
  const _$CoachMessageListCWProxyImpl(this._value);

  final CoachMessageList _value;

  @override
  CoachMessageList items(List<CoachMessage> items) => this(items: items);

  @override
  CoachMessageList nextCursor(String? nextCursor) =>
      this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachMessageList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachMessageList(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachMessageList call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return CoachMessageList(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<CoachMessage>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $CoachMessageListCopyWith on CoachMessageList {
  /// Returns a callable class that can be used as follows: `instanceOfCoachMessageList.copyWith(...)` or like so:`instanceOfCoachMessageList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachMessageListCWProxy get copyWith => _$CoachMessageListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachMessageList _$CoachMessageListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CoachMessageList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items', 'next_cursor']);
      final val = CoachMessageList(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => CoachMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$CoachMessageListToJson(CoachMessageList instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next_cursor': instance.nextCursor,
    };
