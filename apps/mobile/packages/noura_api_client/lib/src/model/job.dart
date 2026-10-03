//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/job_status.dart';
import 'package:noura_api_client/src/model/safe_error.dart';
import 'package:noura_api_client/src/model/job_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'job.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Job {
  /// Returns a new [Job] instance.
  Job({
    required this.id,

    required this.type,

    required this.status,

    required this.resultIds,

    required this.error,

    required this.pollAfterMs,

    required this.createdAt,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final JobType type;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final JobStatus status;

  @JsonKey(name: r'result_ids', required: true, includeIfNull: false)
  final Map<String, String> resultIds;

  @JsonKey(name: r'error', required: true, includeIfNull: true)
  final SafeError? error;

  /// Suggested delay before the next poll; null once the job is terminal.
  // minimum: 2000
  // maximum: 10000
  @JsonKey(name: r'poll_after_ms', required: true, includeIfNull: true)
  final int? pollAfterMs;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updated_at', required: true, includeIfNull: false)
  final DateTime updatedAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Job &&
            runtimeType == other.runtimeType &&
            equals(
              [
                id,
                type,
                status,
                resultIds,
                error,
                pollAfterMs,
                createdAt,
                updatedAt,
              ],
              [
                other.id,
                other.type,
                other.status,
                other.resultIds,
                other.error,
                other.pollAfterMs,
                other.createdAt,
                other.updatedAt,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        id,
        type,
        status,
        resultIds,
        error,
        pollAfterMs,
        createdAt,
        updatedAt,
      ]);

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
