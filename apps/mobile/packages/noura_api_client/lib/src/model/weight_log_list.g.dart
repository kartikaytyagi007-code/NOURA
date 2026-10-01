// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightLogListCWProxy {
  WeightLogList items(List<WeightLog> items);

  WeightLogList nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLogList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLogList(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLogList call({List<WeightLog> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightLogList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightLogList.copyWith.fieldName(...)`
class _$WeightLogListCWProxyImpl implements _$WeightLogListCWProxy {
  const _$WeightLogListCWProxyImpl(this._value);

  final WeightLogList _value;

  @override
  WeightLogList items(List<WeightLog> items) => this(items: items);

  @override
  WeightLogList nextCursor(String? nextCursor) => this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightLogList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightLogList(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightLogList call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return WeightLogList(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<WeightLog>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $WeightLogListCopyWith on WeightLogList {
  /// Returns a callable class that can be used as follows: `instanceOfWeightLogList.copyWith(...)` or like so:`instanceOfWeightLogList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightLogListCWProxy get copyWith => _$WeightLogListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightLogList _$WeightLogListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeightLogList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items', 'next_cursor']);
      final val = WeightLogList(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => WeightLog.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$WeightLogListToJson(WeightLogList instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next_cursor': instance.nextCursor,
    };
