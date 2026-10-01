// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deletion_accepted.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeletionAcceptedCWProxy {
  DeletionAccepted deletionRequestId(String deletionRequestId);

  DeletionAccepted state(DeletionAcceptedStateEnum state);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeletionAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeletionAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  DeletionAccepted call({
    String deletionRequestId,
    DeletionAcceptedStateEnum state,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeletionAccepted.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeletionAccepted.copyWith.fieldName(...)`
class _$DeletionAcceptedCWProxyImpl implements _$DeletionAcceptedCWProxy {
  const _$DeletionAcceptedCWProxyImpl(this._value);

  final DeletionAccepted _value;

  @override
  DeletionAccepted deletionRequestId(String deletionRequestId) =>
      this(deletionRequestId: deletionRequestId);

  @override
  DeletionAccepted state(DeletionAcceptedStateEnum state) => this(state: state);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeletionAccepted(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeletionAccepted(...).copyWith(id: 12, name: "My name")
  /// ````
  DeletionAccepted call({
    Object? deletionRequestId = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
  }) {
    return DeletionAccepted(
      deletionRequestId: deletionRequestId == const $CopyWithPlaceholder()
          ? _value.deletionRequestId
          // ignore: cast_nullable_to_non_nullable
          : deletionRequestId as String,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as DeletionAcceptedStateEnum,
    );
  }
}

extension $DeletionAcceptedCopyWith on DeletionAccepted {
  /// Returns a callable class that can be used as follows: `instanceOfDeletionAccepted.copyWith(...)` or like so:`instanceOfDeletionAccepted.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeletionAcceptedCWProxy get copyWith => _$DeletionAcceptedCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeletionAccepted _$DeletionAcceptedFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeletionAccepted', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['deletion_request_id', 'state']);
      final val = DeletionAccepted(
        deletionRequestId: $checkedConvert(
          'deletion_request_id',
          (v) => v as String,
        ),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$DeletionAcceptedStateEnumEnumMap, v),
        ),
      );
      return val;
    }, fieldKeyMap: const {'deletionRequestId': 'deletion_request_id'});

Map<String, dynamic> _$DeletionAcceptedToJson(DeletionAccepted instance) =>
    <String, dynamic>{
      'deletion_request_id': instance.deletionRequestId,
      'state': _$DeletionAcceptedStateEnumEnumMap[instance.state]!,
    };

const _$DeletionAcceptedStateEnumEnumMap = {
  DeletionAcceptedStateEnum.requested: 'requested',
  DeletionAcceptedStateEnum.inProgress: 'in_progress',
};
