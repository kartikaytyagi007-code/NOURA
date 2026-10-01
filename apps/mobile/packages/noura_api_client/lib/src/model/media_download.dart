//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'media_download.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MediaDownload {
  /// Returns a new [MediaDownload] instance.
  MediaDownload({required this.url, required this.expiresAt});

  @JsonKey(name: r'url', required: true, includeIfNull: false)
  final String url;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MediaDownload &&
            runtimeType == other.runtimeType &&
            equals([url, expiresAt], [other.url, other.expiresAt]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([url, expiresAt]);

  factory MediaDownload.fromJson(Map<String, dynamic> json) =>
      _$MediaDownloadFromJson(json);

  Map<String, dynamic> toJson() => _$MediaDownloadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
