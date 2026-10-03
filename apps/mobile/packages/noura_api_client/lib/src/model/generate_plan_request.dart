//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'generate_plan_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GeneratePlanRequest {
  /// Returns a new [GeneratePlanRequest] instance.
  GeneratePlanRequest({required this.startDate, required this.profileRevision});

  @JsonKey(name: r'start_date', required: true, includeIfNull: false)
  final DateTime startDate;

  // minimum: 1
  @JsonKey(name: r'profile_revision', required: true, includeIfNull: false)
  final int profileRevision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GeneratePlanRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [startDate, profileRevision],
              [other.startDate, other.profileRevision],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([startDate, profileRevision]);

  factory GeneratePlanRequest.fromJson(Map<String, dynamic> json) =>
      _$GeneratePlanRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratePlanRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
