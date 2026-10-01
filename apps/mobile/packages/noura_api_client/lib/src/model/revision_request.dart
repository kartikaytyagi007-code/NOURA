//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'revision_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RevisionRequest {
  /// Returns a new [RevisionRequest] instance.
  RevisionRequest({required this.expectedRevision});

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RevisionRequest &&
            runtimeType == other.runtimeType &&
            equals([expectedRevision], [other.expectedRevision]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([expectedRevision]);

  factory RevisionRequest.fromJson(Map<String, dynamic> json) =>
      _$RevisionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RevisionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
