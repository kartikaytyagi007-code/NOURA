//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/photo_angle.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'create_progress_photo_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateProgressPhotoRequest {
  /// Returns a new [CreateProgressPhotoRequest] instance.
  CreateProgressPhotoRequest({
    required this.mediaId,

    required this.capturedAt,

    required this.angle,
  });

  @JsonKey(name: r'media_id', required: true, includeIfNull: false)
  final String mediaId;

  @JsonKey(name: r'captured_at', required: true, includeIfNull: false)
  final DateTime capturedAt;

  @JsonKey(name: r'angle', required: true, includeIfNull: false)
  final PhotoAngle angle;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CreateProgressPhotoRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [mediaId, capturedAt, angle],
              [other.mediaId, other.capturedAt, other.angle],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([mediaId, capturedAt, angle]);

  factory CreateProgressPhotoRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProgressPhotoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProgressPhotoRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
