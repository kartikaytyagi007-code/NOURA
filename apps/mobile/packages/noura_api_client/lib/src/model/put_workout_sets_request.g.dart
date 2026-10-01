// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_workout_sets_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PutWorkoutSetsRequestCWProxy {
  PutWorkoutSetsRequest expectedRevision(int expectedRevision);

  PutWorkoutSetsRequest sets(List<SetLogInput> sets);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PutWorkoutSetsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PutWorkoutSetsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PutWorkoutSetsRequest call({int expectedRevision, List<SetLogInput> sets});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPutWorkoutSetsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPutWorkoutSetsRequest.copyWith.fieldName(...)`
class _$PutWorkoutSetsRequestCWProxyImpl
    implements _$PutWorkoutSetsRequestCWProxy {
  const _$PutWorkoutSetsRequestCWProxyImpl(this._value);

  final PutWorkoutSetsRequest _value;

  @override
  PutWorkoutSetsRequest expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  PutWorkoutSetsRequest sets(List<SetLogInput> sets) => this(sets: sets);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PutWorkoutSetsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PutWorkoutSetsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PutWorkoutSetsRequest call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? sets = const $CopyWithPlaceholder(),
  }) {
    return PutWorkoutSetsRequest(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      sets: sets == const $CopyWithPlaceholder()
          ? _value.sets
          // ignore: cast_nullable_to_non_nullable
          : sets as List<SetLogInput>,
    );
  }
}

extension $PutWorkoutSetsRequestCopyWith on PutWorkoutSetsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPutWorkoutSetsRequest.copyWith(...)` or like so:`instanceOfPutWorkoutSetsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PutWorkoutSetsRequestCWProxy get copyWith =>
      _$PutWorkoutSetsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutWorkoutSetsRequest _$PutWorkoutSetsRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PutWorkoutSetsRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['expected_revision', 'sets']);
  final val = PutWorkoutSetsRequest(
    expectedRevision: $checkedConvert(
      'expected_revision',
      (v) => (v as num).toInt(),
    ),
    sets: $checkedConvert(
      'sets',
      (v) => (v as List<dynamic>)
          .map((e) => SetLogInput.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'expectedRevision': 'expected_revision'});

Map<String, dynamic> _$PutWorkoutSetsRequestToJson(
  PutWorkoutSetsRequest instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'sets': instance.sets.map((e) => e.toJson()).toList(),
};
