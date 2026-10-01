//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/deletion_accepted.dart';
import 'package:noura_api_client/src/model/meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'deletion_accepted_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeletionAcceptedResponse {
  /// Returns a new [DeletionAcceptedResponse] instance.
  DeletionAcceptedResponse({required this.data, required this.meta});

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final DeletionAccepted data;

  @JsonKey(name: r'meta', required: true, includeIfNull: false)
  final Meta meta;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DeletionAcceptedResponse &&
            runtimeType == other.runtimeType &&
            equals([data, meta], [other.data, other.meta]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([data, meta]);

  factory DeletionAcceptedResponse.fromJson(Map<String, dynamic> json) =>
      _$DeletionAcceptedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeletionAcceptedResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
