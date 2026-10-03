//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'export_accepted.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExportAccepted {
  /// Returns a new [ExportAccepted] instance.
  ExportAccepted({required this.exportId, required this.jobId});

  @JsonKey(name: r'export_id', required: true, includeIfNull: false)
  final String exportId;

  @JsonKey(name: r'job_id', required: true, includeIfNull: false)
  final String jobId;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExportAccepted &&
            runtimeType == other.runtimeType &&
            equals([exportId, jobId], [other.exportId, other.jobId]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([exportId, jobId]);

  factory ExportAccepted.fromJson(Map<String, dynamic> json) =>
      _$ExportAcceptedFromJson(json);

  Map<String, dynamic> toJson() => _$ExportAcceptedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
