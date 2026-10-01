// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'substitutions_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubstitutionsResponseCWProxy {
  SubstitutionsResponse data(Substitutions data);

  SubstitutionsResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubstitutionsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubstitutionsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SubstitutionsResponse call({Substitutions data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubstitutionsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubstitutionsResponse.copyWith.fieldName(...)`
class _$SubstitutionsResponseCWProxyImpl
    implements _$SubstitutionsResponseCWProxy {
  const _$SubstitutionsResponseCWProxyImpl(this._value);

  final SubstitutionsResponse _value;

  @override
  SubstitutionsResponse data(Substitutions data) => this(data: data);

  @override
  SubstitutionsResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SubstitutionsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SubstitutionsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SubstitutionsResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return SubstitutionsResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Substitutions,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $SubstitutionsResponseCopyWith on SubstitutionsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSubstitutionsResponse.copyWith(...)` or like so:`instanceOfSubstitutionsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubstitutionsResponseCWProxy get copyWith =>
      _$SubstitutionsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubstitutionsResponse _$SubstitutionsResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SubstitutionsResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = SubstitutionsResponse(
    data: $checkedConvert(
      'data',
      (v) => Substitutions.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SubstitutionsResponseToJson(
  SubstitutionsResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
