// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RevisionRequestCWProxy {
  RevisionRequest expectedRevision(int expectedRevision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevisionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevisionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RevisionRequest call({int expectedRevision});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRevisionRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRevisionRequest.copyWith.fieldName(...)`
class _$RevisionRequestCWProxyImpl implements _$RevisionRequestCWProxy {
  const _$RevisionRequestCWProxyImpl(this._value);

  final RevisionRequest _value;

  @override
  RevisionRequest expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevisionRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevisionRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RevisionRequest call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
  }) {
    return RevisionRequest(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
    );
  }
}

extension $RevisionRequestCopyWith on RevisionRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRevisionRequest.copyWith(...)` or like so:`instanceOfRevisionRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RevisionRequestCWProxy get copyWith => _$RevisionRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevisionRequest _$RevisionRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RevisionRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['expected_revision']);
      final val = RevisionRequest(
        expectedRevision: $checkedConvert(
          'expected_revision',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'expectedRevision': 'expected_revision'});

Map<String, dynamic> _$RevisionRequestToJson(RevisionRequest instance) =>
    <String, dynamic>{'expected_revision': instance.expectedRevision};
