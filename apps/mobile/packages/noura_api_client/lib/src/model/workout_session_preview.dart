//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'workout_session_preview.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WorkoutSessionPreview {
  /// Returns a new [WorkoutSessionPreview] instance.
  WorkoutSessionPreview({
    required this.sessionId,

    required this.title,

    required this.status,
  });

  @JsonKey(name: r'session_id', required: true, includeIfNull: false)
  final String sessionId;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final WorkoutSessionPreviewStatusEnum status;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WorkoutSessionPreview &&
            runtimeType == other.runtimeType &&
            equals(
              [sessionId, title, status],
              [other.sessionId, other.title, other.status],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([sessionId, title, status]);

  factory WorkoutSessionPreview.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionPreviewFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutSessionPreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum WorkoutSessionPreviewStatusEnum {
  @JsonValue(r'scheduled')
  scheduled(r'scheduled'),
  @JsonValue(r'rescheduled')
  rescheduled(r'rescheduled'),
  @JsonValue(r'cancelled')
  cancelled(r'cancelled'),
  @JsonValue(r'completed')
  completed(r'completed'),
  @JsonValue(r'skipped')
  skipped(r'skipped');

  const WorkoutSessionPreviewStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
