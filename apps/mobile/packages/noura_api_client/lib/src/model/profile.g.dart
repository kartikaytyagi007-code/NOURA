// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProfileCWProxy {
  Profile displayName(String? displayName);

  Profile ageYears(int? ageYears);

  Profile calculationSex(CalculationSex? calculationSex);

  Profile heightCm(num? heightCm);

  Profile activityBand(ActivityBand? activityBand);

  Profile timezone(String timezone);

  Profile unitSystem(UnitSystem unitSystem);

  Profile revision(int revision);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Profile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Profile(...).copyWith(id: 12, name: "My name")
  /// ````
  Profile call({
    String? displayName,
    int? ageYears,
    CalculationSex? calculationSex,
    num? heightCm,
    ActivityBand? activityBand,
    String timezone,
    UnitSystem unitSystem,
    int revision,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProfile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProfile.copyWith.fieldName(...)`
class _$ProfileCWProxyImpl implements _$ProfileCWProxy {
  const _$ProfileCWProxyImpl(this._value);

  final Profile _value;

  @override
  Profile displayName(String? displayName) => this(displayName: displayName);

  @override
  Profile ageYears(int? ageYears) => this(ageYears: ageYears);

  @override
  Profile calculationSex(CalculationSex? calculationSex) =>
      this(calculationSex: calculationSex);

  @override
  Profile heightCm(num? heightCm) => this(heightCm: heightCm);

  @override
  Profile activityBand(ActivityBand? activityBand) =>
      this(activityBand: activityBand);

  @override
  Profile timezone(String timezone) => this(timezone: timezone);

  @override
  Profile unitSystem(UnitSystem unitSystem) => this(unitSystem: unitSystem);

  @override
  Profile revision(int revision) => this(revision: revision);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Profile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Profile(...).copyWith(id: 12, name: "My name")
  /// ````
  Profile call({
    Object? displayName = const $CopyWithPlaceholder(),
    Object? ageYears = const $CopyWithPlaceholder(),
    Object? calculationSex = const $CopyWithPlaceholder(),
    Object? heightCm = const $CopyWithPlaceholder(),
    Object? activityBand = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? unitSystem = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
  }) {
    return Profile(
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
      ageYears: ageYears == const $CopyWithPlaceholder()
          ? _value.ageYears
          // ignore: cast_nullable_to_non_nullable
          : ageYears as int?,
      calculationSex: calculationSex == const $CopyWithPlaceholder()
          ? _value.calculationSex
          // ignore: cast_nullable_to_non_nullable
          : calculationSex as CalculationSex?,
      heightCm: heightCm == const $CopyWithPlaceholder()
          ? _value.heightCm
          // ignore: cast_nullable_to_non_nullable
          : heightCm as num?,
      activityBand: activityBand == const $CopyWithPlaceholder()
          ? _value.activityBand
          // ignore: cast_nullable_to_non_nullable
          : activityBand as ActivityBand?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      unitSystem: unitSystem == const $CopyWithPlaceholder()
          ? _value.unitSystem
          // ignore: cast_nullable_to_non_nullable
          : unitSystem as UnitSystem,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
    );
  }
}

extension $ProfileCopyWith on Profile {
  /// Returns a callable class that can be used as follows: `instanceOfProfile.copyWith(...)` or like so:`instanceOfProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProfileCWProxy get copyWith => _$ProfileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Profile',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'display_name',
        'age_years',
        'calculation_sex',
        'height_cm',
        'activity_band',
        'timezone',
        'unit_system',
        'revision',
      ],
    );
    final val = Profile(
      displayName: $checkedConvert('display_name', (v) => v as String?),
      ageYears: $checkedConvert('age_years', (v) => (v as num?)?.toInt()),
      calculationSex: $checkedConvert(
        'calculation_sex',
        (v) => $enumDecodeNullable(_$CalculationSexEnumMap, v),
      ),
      heightCm: $checkedConvert('height_cm', (v) => v as num?),
      activityBand: $checkedConvert(
        'activity_band',
        (v) => $enumDecodeNullable(_$ActivityBandEnumMap, v),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String),
      unitSystem: $checkedConvert(
        'unit_system',
        (v) => $enumDecode(_$UnitSystemEnumMap, v),
      ),
      revision: $checkedConvert('revision', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'ageYears': 'age_years',
    'calculationSex': 'calculation_sex',
    'heightCm': 'height_cm',
    'activityBand': 'activity_band',
    'unitSystem': 'unit_system',
  },
);

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
  'display_name': instance.displayName,
  'age_years': instance.ageYears,
  'calculation_sex': _$CalculationSexEnumMap[instance.calculationSex],
  'height_cm': instance.heightCm,
  'activity_band': _$ActivityBandEnumMap[instance.activityBand],
  'timezone': instance.timezone,
  'unit_system': _$UnitSystemEnumMap[instance.unitSystem]!,
  'revision': instance.revision,
};

const _$CalculationSexEnumMap = {
  CalculationSex.female: 'female',
  CalculationSex.male: 'male',
};

const _$ActivityBandEnumMap = {
  ActivityBand.sedentary: 'sedentary',
  ActivityBand.light: 'light',
  ActivityBand.moderate: 'moderate',
  ActivityBand.active: 'active',
  ActivityBand.veryActive: 'very_active',
};

const _$UnitSystemEnumMap = {
  UnitSystem.metric: 'metric',
  UnitSystem.imperial: 'imperial',
};
