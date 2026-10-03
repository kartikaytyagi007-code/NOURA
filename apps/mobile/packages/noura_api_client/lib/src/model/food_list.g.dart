// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_list.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FoodListCWProxy {
  FoodList items(List<Food> items);

  FoodList nextCursor(String? nextCursor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FoodList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FoodList(...).copyWith(id: 12, name: "My name")
  /// ````
  FoodList call({List<Food> items, String? nextCursor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFoodList.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFoodList.copyWith.fieldName(...)`
class _$FoodListCWProxyImpl implements _$FoodListCWProxy {
  const _$FoodListCWProxyImpl(this._value);

  final FoodList _value;

  @override
  FoodList items(List<Food> items) => this(items: items);

  @override
  FoodList nextCursor(String? nextCursor) => this(nextCursor: nextCursor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FoodList(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FoodList(...).copyWith(id: 12, name: "My name")
  /// ````
  FoodList call({
    Object? items = const $CopyWithPlaceholder(),
    Object? nextCursor = const $CopyWithPlaceholder(),
  }) {
    return FoodList(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<Food>,
      nextCursor: nextCursor == const $CopyWithPlaceholder()
          ? _value.nextCursor
          // ignore: cast_nullable_to_non_nullable
          : nextCursor as String?,
    );
  }
}

extension $FoodListCopyWith on FoodList {
  /// Returns a callable class that can be used as follows: `instanceOfFoodList.copyWith(...)` or like so:`instanceOfFoodList.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FoodListCWProxy get copyWith => _$FoodListCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodList _$FoodListFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FoodList', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items', 'next_cursor']);
      final val = FoodList(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => Food.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('next_cursor', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'nextCursor': 'next_cursor'});

Map<String, dynamic> _$FoodListToJson(FoodList instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'next_cursor': instance.nextCursor,
};
