//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/meta.dart';
import 'package:noura_api_client/src/model/progress_photo_list.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'progress_photo_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProgressPhotoListResponse {
  /// Returns a new [ProgressPhotoListResponse] instance.
  ProgressPhotoListResponse({required this.data, required this.meta});

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final ProgressPhotoList data;

  @JsonKey(name: r'meta', required: true, includeIfNull: false)
  final Meta meta;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProgressPhotoListResponse &&
            runtimeType == other.runtimeType &&
            equals([data, meta], [other.data, other.meta]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([data, meta]);

  factory ProgressPhotoListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgressPhotoListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressPhotoListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
