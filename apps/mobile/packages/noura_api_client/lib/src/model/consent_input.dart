//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/consent_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'consent_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConsentInput {
  /// Returns a new [ConsentInput] instance.
  ConsentInput({required this.consentType, required this.version});

  @JsonKey(name: r'consent_type', required: true, includeIfNull: false)
  final ConsentType consentType;

  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final String version;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ConsentInput &&
            runtimeType == other.runtimeType &&
            equals([consentType, version], [other.consentType, other.version]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([consentType, version]);

  factory ConsentInput.fromJson(Map<String, dynamic> json) =>
      _$ConsentInputFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
