// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_items_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConfirmItemsRequestCWProxy {
  ConfirmItemsRequest expectedRevision(int expectedRevision);

  ConfirmItemsRequest items(List<ConfirmedItemInput> items);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmItemsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmItemsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmItemsRequest call({
    int expectedRevision,
    List<ConfirmedItemInput> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConfirmItemsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConfirmItemsRequest.copyWith.fieldName(...)`
class _$ConfirmItemsRequestCWProxyImpl implements _$ConfirmItemsRequestCWProxy {
  const _$ConfirmItemsRequestCWProxyImpl(this._value);

  final ConfirmItemsRequest _value;

  @override
  ConfirmItemsRequest expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  ConfirmItemsRequest items(List<ConfirmedItemInput> items) =>
      this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConfirmItemsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConfirmItemsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ConfirmItemsRequest call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return ConfirmItemsRequest(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<ConfirmedItemInput>,
    );
  }
}

extension $ConfirmItemsRequestCopyWith on ConfirmItemsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfConfirmItemsRequest.copyWith(...)` or like so:`instanceOfConfirmItemsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConfirmItemsRequestCWProxy get copyWith =>
      _$ConfirmItemsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmItemsRequest _$ConfirmItemsRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConfirmItemsRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['expected_revision', 'items']);
      final val = ConfirmItemsRequest(
        expectedRevision: $checkedConvert(
          'expected_revision',
          (v) => (v as num).toInt(),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map(
                (e) => ConfirmedItemInput.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'expectedRevision': 'expected_revision'});

Map<String, dynamic> _$ConfirmItemsRequestToJson(
  ConfirmItemsRequest instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
