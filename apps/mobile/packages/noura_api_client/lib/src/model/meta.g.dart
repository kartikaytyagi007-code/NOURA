// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MetaCWProxy {
  Meta requestId(String requestId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Meta(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Meta(...).copyWith(id: 12, name: "My name")
  /// ````
  Meta call({String requestId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeta.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeta.copyWith.fieldName(...)`
class _$MetaCWProxyImpl implements _$MetaCWProxy {
  const _$MetaCWProxyImpl(this._value);

  final Meta _value;

  @override
  Meta requestId(String requestId) => this(requestId: requestId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Meta(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Meta(...).copyWith(id: 12, name: "My name")
  /// ````
  Meta call({Object? requestId = const $CopyWithPlaceholder()}) {
    return Meta(
      requestId: requestId == const $CopyWithPlaceholder()
          ? _value.requestId
          // ignore: cast_nullable_to_non_nullable
          : requestId as String,
    );
  }
}

extension $MetaCopyWith on Meta {
  /// Returns a callable class that can be used as follows: `instanceOfMeta.copyWith(...)` or like so:`instanceOfMeta.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MetaCWProxy get copyWith => _$MetaCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meta _$MetaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Meta', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['request_id']);
      final val = Meta(
        requestId: $checkedConvert('request_id', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'requestId': 'request_id'});

Map<String, dynamic> _$MetaToJson(Meta instance) => <String, dynamic>{
  'request_id': instance.requestId,
};
