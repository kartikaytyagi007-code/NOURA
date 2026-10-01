//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'job_accepted.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class JobAccepted {
  /// Returns a new [JobAccepted] instance.
  JobAccepted({required this.jobId});

  @JsonKey(name: r'job_id', required: true, includeIfNull: false)
  final String jobId;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is JobAccepted &&
            runtimeType == other.runtimeType &&
            equals([jobId], [other.jobId]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([jobId]);

  factory JobAccepted.fromJson(Map<String, dynamic> json) =>
      _$JobAcceptedFromJson(json);

  Map<String, dynamic> toJson() => _$JobAcceptedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
