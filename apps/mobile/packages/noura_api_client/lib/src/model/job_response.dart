//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/job.dart';
import 'package:noura_api_client/src/model/meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'job_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class JobResponse {
  /// Returns a new [JobResponse] instance.
  JobResponse({required this.data, required this.meta});

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final Job data;

  @JsonKey(name: r'meta', required: true, includeIfNull: false)
  final Meta meta;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is JobResponse &&
            runtimeType == other.runtimeType &&
            equals([data, meta], [other.data, other.meta]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([data, meta]);

  factory JobResponse.fromJson(Map<String, dynamic> json) =>
      _$JobResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JobResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
