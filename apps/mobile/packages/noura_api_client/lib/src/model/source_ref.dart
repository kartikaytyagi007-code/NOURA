//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'source_ref.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SourceRef {
  /// Returns a new [SourceRef] instance.
  SourceRef({
    required this.sourceId,

    required this.sourceName,

    required this.sourceVersion,
  });

  @JsonKey(name: r'source_id', required: true, includeIfNull: false)
  final String sourceId;

  @JsonKey(name: r'source_name', required: true, includeIfNull: false)
  final String sourceName;

  @JsonKey(name: r'source_version', required: true, includeIfNull: false)
  final String sourceVersion;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SourceRef &&
            runtimeType == other.runtimeType &&
            equals(
              [sourceId, sourceName, sourceVersion],
              [other.sourceId, other.sourceName, other.sourceVersion],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([sourceId, sourceName, sourceVersion]);

  factory SourceRef.fromJson(Map<String, dynamic> json) =>
      _$SourceRefFromJson(json);

  Map<String, dynamic> toJson() => _$SourceRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
