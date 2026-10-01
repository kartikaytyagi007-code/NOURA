//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'create_meal_scan_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateMealScanRequest {
  /// Returns a new [CreateMealScanRequest] instance.
  CreateMealScanRequest({required this.mediaId});

  @JsonKey(name: r'media_id', required: true, includeIfNull: false)
  final String mediaId;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CreateMealScanRequest &&
            runtimeType == other.runtimeType &&
            equals([mediaId], [other.mediaId]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([mediaId]);

  factory CreateMealScanRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMealScanRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMealScanRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
