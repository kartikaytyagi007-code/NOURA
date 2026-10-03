// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_plan_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GeneratePlanRequestCWProxy {
  GeneratePlanRequest startDate(DateTime startDate);

  GeneratePlanRequest profileRevision(int profileRevision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneratePlanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneratePlanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneratePlanRequest call({DateTime startDate, int profileRevision});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGeneratePlanRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGeneratePlanRequest.copyWith.fieldName(...)`
class _$GeneratePlanRequestCWProxyImpl implements _$GeneratePlanRequestCWProxy {
  const _$GeneratePlanRequestCWProxyImpl(this._value);

  final GeneratePlanRequest _value;

  @override
  GeneratePlanRequest startDate(DateTime startDate) =>
      this(startDate: startDate);

  @override
  GeneratePlanRequest profileRevision(int profileRevision) =>
      this(profileRevision: profileRevision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GeneratePlanRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GeneratePlanRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GeneratePlanRequest call({
    Object? startDate = const $CopyWithPlaceholder(),
    Object? profileRevision = const $CopyWithPlaceholder(),
  }) {
    return GeneratePlanRequest(
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as DateTime,
      profileRevision: profileRevision == const $CopyWithPlaceholder()
          ? _value.profileRevision
          // ignore: cast_nullable_to_non_nullable
          : profileRevision as int,
    );
  }
}

extension $GeneratePlanRequestCopyWith on GeneratePlanRequest {
  /// Returns a callable class that can be used as follows: `instanceOfGeneratePlanRequest.copyWith(...)` or like so:`instanceOfGeneratePlanRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GeneratePlanRequestCWProxy get copyWith =>
      _$GeneratePlanRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratePlanRequest _$GeneratePlanRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'GeneratePlanRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['start_date', 'profile_revision'],
        );
        final val = GeneratePlanRequest(
          startDate: $checkedConvert(
            'start_date',
            (v) => DateTime.parse(v as String),
          ),
          profileRevision: $checkedConvert(
            'profile_revision',
            (v) => (v as num).toInt(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'startDate': 'start_date',
        'profileRevision': 'profile_revision',
      },
    );

Map<String, dynamic> _$GeneratePlanRequestToJson(
  GeneratePlanRequest instance,
) => <String, dynamic>{
  'start_date': instance.startDate.toIso8601String(),
  'profile_revision': instance.profileRevision,
};
