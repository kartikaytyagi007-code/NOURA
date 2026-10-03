//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'send_coach_message_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendCoachMessageRequest {
  /// Returns a new [SendCoachMessageRequest] instance.
  SendCoachMessageRequest({required this.clientId, required this.message});

  @JsonKey(name: r'client_id', required: true, includeIfNull: false)
  final String clientId;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SendCoachMessageRequest &&
            runtimeType == other.runtimeType &&
            equals([clientId, message], [other.clientId, other.message]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([clientId, message]);

  factory SendCoachMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendCoachMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendCoachMessageRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
