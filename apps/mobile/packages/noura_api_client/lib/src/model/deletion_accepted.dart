//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'deletion_accepted.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeletionAccepted {
  /// Returns a new [DeletionAccepted] instance.
  DeletionAccepted({required this.deletionRequestId, required this.state});

  @JsonKey(name: r'deletion_request_id', required: true, includeIfNull: false)
  final String deletionRequestId;

  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final DeletionAcceptedStateEnum state;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DeletionAccepted &&
            runtimeType == other.runtimeType &&
            equals(
              [deletionRequestId, state],
              [other.deletionRequestId, other.state],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([deletionRequestId, state]);

  factory DeletionAccepted.fromJson(Map<String, dynamic> json) =>
      _$DeletionAcceptedFromJson(json);

  Map<String, dynamic> toJson() => _$DeletionAcceptedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DeletionAcceptedStateEnum {
  @JsonValue(r'requested')
  requested(r'requested'),
  @JsonValue(r'in_progress')
  inProgress(r'in_progress');

  const DeletionAcceptedStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
