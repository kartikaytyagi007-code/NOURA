//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/activity_band.dart';
import 'package:noura_api_client/src/model/calculation_sex.dart';
import 'package:noura_api_client/src/model/unit_system.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'profile.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Profile {
  /// Returns a new [Profile] instance.
  Profile({
    required this.displayName,

    required this.ageYears,

    required this.calculationSex,

    required this.heightCm,

    required this.activityBand,

    required this.timezone,

    required this.unitSystem,

    required this.revision,
  });

  @JsonKey(name: r'display_name', required: true, includeIfNull: true)
  final String? displayName;

  // minimum: 1
  // maximum: 120
  @JsonKey(name: r'age_years', required: true, includeIfNull: true)
  final int? ageYears;

  @JsonKey(name: r'calculation_sex', required: true, includeIfNull: true)
  final CalculationSex? calculationSex;

  // minimum: 50
  // maximum: 272
  @JsonKey(name: r'height_cm', required: true, includeIfNull: true)
  final num? heightCm;

  @JsonKey(name: r'activity_band', required: true, includeIfNull: true)
  final ActivityBand? activityBand;

  /// IANA timezone.
  @JsonKey(name: r'timezone', required: true, includeIfNull: false)
  final String timezone;

  @JsonKey(name: r'unit_system', required: true, includeIfNull: false)
  final UnitSystem unitSystem;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Profile &&
            runtimeType == other.runtimeType &&
            equals(
              [
                displayName,
                ageYears,
                calculationSex,
                heightCm,
                activityBand,
                timezone,
                unitSystem,
                revision,
              ],
              [
                other.displayName,
                other.ageYears,
                other.calculationSex,
                other.heightCm,
                other.activityBand,
                other.timezone,
                other.unitSystem,
                other.revision,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        displayName,
        ageYears,
        calculationSex,
        heightCm,
        activityBand,
        timezone,
        unitSystem,
        revision,
      ]);

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
