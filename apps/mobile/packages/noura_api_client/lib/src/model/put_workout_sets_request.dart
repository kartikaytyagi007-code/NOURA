//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/set_log_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'put_workout_sets_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PutWorkoutSetsRequest {
  /// Returns a new [PutWorkoutSetsRequest] instance.
  PutWorkoutSetsRequest({required this.expectedRevision, required this.sets});

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'sets', required: true, includeIfNull: false)
  final List<SetLogInput> sets;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PutWorkoutSetsRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [expectedRevision, sets],
              [other.expectedRevision, other.sets],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([expectedRevision, sets]);

  factory PutWorkoutSetsRequest.fromJson(Map<String, dynamic> json) =>
      _$PutWorkoutSetsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PutWorkoutSetsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
