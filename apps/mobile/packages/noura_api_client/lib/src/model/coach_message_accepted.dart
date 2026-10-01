//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/coach_message.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'coach_message_accepted.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoachMessageAccepted {
  /// Returns a new [CoachMessageAccepted] instance.
  CoachMessageAccepted({required this.jobId, required this.message});

  @JsonKey(name: r'job_id', required: true, includeIfNull: false)
  final String jobId;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final CoachMessage message;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CoachMessageAccepted &&
            runtimeType == other.runtimeType &&
            equals([jobId, message], [other.jobId, other.message]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([jobId, message]);

  factory CoachMessageAccepted.fromJson(Map<String, dynamic> json) =>
      _$CoachMessageAcceptedFromJson(json);

  Map<String, dynamic> toJson() => _$CoachMessageAcceptedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
