// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'replace_plan_meal_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReplacePlanMealRequestCWProxy {
  ReplacePlanMealRequest expectedRevision(int expectedRevision);

  ReplacePlanMealRequest candidateId(String candidateId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplacePlanMealRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplacePlanMealRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplacePlanMealRequest call({int expectedRevision, String candidateId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReplacePlanMealRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReplacePlanMealRequest.copyWith.fieldName(...)`
class _$ReplacePlanMealRequestCWProxyImpl
    implements _$ReplacePlanMealRequestCWProxy {
  const _$ReplacePlanMealRequestCWProxyImpl(this._value);

  final ReplacePlanMealRequest _value;

  @override
  ReplacePlanMealRequest expectedRevision(int expectedRevision) =>
      this(expectedRevision: expectedRevision);

  @override
  ReplacePlanMealRequest candidateId(String candidateId) =>
      this(candidateId: candidateId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReplacePlanMealRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReplacePlanMealRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReplacePlanMealRequest call({
    Object? expectedRevision = const $CopyWithPlaceholder(),
    Object? candidateId = const $CopyWithPlaceholder(),
  }) {
    return ReplacePlanMealRequest(
      expectedRevision: expectedRevision == const $CopyWithPlaceholder()
          ? _value.expectedRevision
          // ignore: cast_nullable_to_non_nullable
          : expectedRevision as int,
      candidateId: candidateId == const $CopyWithPlaceholder()
          ? _value.candidateId
          // ignore: cast_nullable_to_non_nullable
          : candidateId as String,
    );
  }
}

extension $ReplacePlanMealRequestCopyWith on ReplacePlanMealRequest {
  /// Returns a callable class that can be used as follows: `instanceOfReplacePlanMealRequest.copyWith(...)` or like so:`instanceOfReplacePlanMealRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReplacePlanMealRequestCWProxy get copyWith =>
      _$ReplacePlanMealRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplacePlanMealRequest _$ReplacePlanMealRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ReplacePlanMealRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['expected_revision', 'candidate_id']);
    final val = ReplacePlanMealRequest(
      expectedRevision: $checkedConvert(
        'expected_revision',
        (v) => (v as num).toInt(),
      ),
      candidateId: $checkedConvert('candidate_id', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'expectedRevision': 'expected_revision',
    'candidateId': 'candidate_id',
  },
);

Map<String, dynamic> _$ReplacePlanMealRequestToJson(
  ReplacePlanMealRequest instance,
) => <String, dynamic>{
  'expected_revision': instance.expectedRevision,
  'candidate_id': instance.candidateId,
};
