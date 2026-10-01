// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_proposal_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActionProposalResponseCWProxy {
  ActionProposalResponse data(ActionProposal data);

  ActionProposalResponse meta(Meta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionProposalResponse call({ActionProposal data, Meta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActionProposalResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActionProposalResponse.copyWith.fieldName(...)`
class _$ActionProposalResponseCWProxyImpl
    implements _$ActionProposalResponseCWProxy {
  const _$ActionProposalResponseCWProxyImpl(this._value);

  final ActionProposalResponse _value;

  @override
  ActionProposalResponse data(ActionProposal data) => this(data: data);

  @override
  ActionProposalResponse meta(Meta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionProposalResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionProposalResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionProposalResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return ActionProposalResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as ActionProposal,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as Meta,
    );
  }
}

extension $ActionProposalResponseCopyWith on ActionProposalResponse {
  /// Returns a callable class that can be used as follows: `instanceOfActionProposalResponse.copyWith(...)` or like so:`instanceOfActionProposalResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActionProposalResponseCWProxy get copyWith =>
      _$ActionProposalResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionProposalResponse _$ActionProposalResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ActionProposalResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = ActionProposalResponse(
    data: $checkedConvert(
      'data',
      (v) => ActionProposal.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => Meta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ActionProposalResponseToJson(
  ActionProposalResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
