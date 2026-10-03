// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeleteAccountRequestCWProxy {
  DeleteAccountRequest confirm(DeleteAccountRequestConfirmEnum confirm);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeleteAccountRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeleteAccountRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DeleteAccountRequest call({DeleteAccountRequestConfirmEnum confirm});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeleteAccountRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeleteAccountRequest.copyWith.fieldName(...)`
class _$DeleteAccountRequestCWProxyImpl
    implements _$DeleteAccountRequestCWProxy {
  const _$DeleteAccountRequestCWProxyImpl(this._value);

  final DeleteAccountRequest _value;

  @override
  DeleteAccountRequest confirm(DeleteAccountRequestConfirmEnum confirm) =>
      this(confirm: confirm);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeleteAccountRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeleteAccountRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  DeleteAccountRequest call({Object? confirm = const $CopyWithPlaceholder()}) {
    return DeleteAccountRequest(
      confirm: confirm == const $CopyWithPlaceholder()
          ? _value.confirm
          // ignore: cast_nullable_to_non_nullable
          : confirm as DeleteAccountRequestConfirmEnum,
    );
  }
}

extension $DeleteAccountRequestCopyWith on DeleteAccountRequest {
  /// Returns a callable class that can be used as follows: `instanceOfDeleteAccountRequest.copyWith(...)` or like so:`instanceOfDeleteAccountRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeleteAccountRequestCWProxy get copyWith =>
      _$DeleteAccountRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteAccountRequest _$DeleteAccountRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DeleteAccountRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['confirm']);
  final val = DeleteAccountRequest(
    confirm: $checkedConvert(
      'confirm',
      (v) => $enumDecode(_$DeleteAccountRequestConfirmEnumEnumMap, v),
    ),
  );
  return val;
});

Map<String, dynamic> _$DeleteAccountRequestToJson(
  DeleteAccountRequest instance,
) => <String, dynamic>{
  'confirm': _$DeleteAccountRequestConfirmEnumEnumMap[instance.confirm]!,
};

const _$DeleteAccountRequestConfirmEnumEnumMap = {
  DeleteAccountRequestConfirmEnum.DELETE_MY_ACCOUNT: 'DELETE_MY_ACCOUNT',
};
