//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'webhook_ack.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WebhookAck {
  /// Returns a new [WebhookAck] instance.
  WebhookAck({required this.received});

  @JsonKey(name: r'received', required: true, includeIfNull: false)
  final bool received;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WebhookAck &&
            runtimeType == other.runtimeType &&
            equals([received], [other.received]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([received]);

  factory WebhookAck.fromJson(Map<String, dynamic> json) =>
      _$WebhookAckFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookAckToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
