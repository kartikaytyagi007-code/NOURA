//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/progress_photo.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'progress_photo_list.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProgressPhotoList {
  /// Returns a new [ProgressPhotoList] instance.
  ProgressPhotoList({required this.items, required this.nextCursor});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ProgressPhoto> items;

  @JsonKey(name: r'next_cursor', required: true, includeIfNull: true)
  final String? nextCursor;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProgressPhotoList &&
            runtimeType == other.runtimeType &&
            equals([items, nextCursor], [other.items, other.nextCursor]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([items, nextCursor]);

  factory ProgressPhotoList.fromJson(Map<String, dynamic> json) =>
      _$ProgressPhotoListFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressPhotoListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
