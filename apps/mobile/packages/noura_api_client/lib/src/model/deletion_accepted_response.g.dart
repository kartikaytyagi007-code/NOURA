// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deletion_accepted_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeletionAcceptedResponseCWProxy {
  DeletionAcceptedResponse data(DeletionAccepted data);

  DeletionAcceptedResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeletionAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeletionAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DeletionAcceptedResponse call({DeletionAccepted data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeletionAcceptedResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeletionAcceptedResponse.copyWith.fieldName(...)`
class _$DeletionAcceptedResponseCWProxyImpl
    implements _$DeletionAcceptedResponseCWProxy {
  const _$DeletionAcceptedResponseCWProxyImpl(this._value);

  final DeletionAcceptedResponse _value;

  @override
  DeletionAcceptedResponse data(DeletionAccepted data) => this(data: data);

  @override
  DeletionAcceptedResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeletionAcceptedResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeletionAcceptedResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DeletionAcceptedResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DeletionAcceptedResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as DeletionAccepted,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $DeletionAcceptedResponseCopyWith on DeletionAcceptedResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDeletionAcceptedResponse.copyWith(...)` or like so:`instanceOfDeletionAcceptedResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeletionAcceptedResponseCWProxy get copyWith =>
      _$DeletionAcceptedResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeletionAcceptedResponse _$DeletionAcceptedResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DeletionAcceptedResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = DeletionAcceptedResponse(
    data: $checkedConvert(
      'data',
      (v) => DeletionAccepted.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DeletionAcceptedResponseToJson(
  DeletionAcceptedResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
