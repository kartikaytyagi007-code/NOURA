//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'revenue_cat_webhook_request_event.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RevenueCatWebhookRequestEvent {
  /// Returns a new [RevenueCatWebhookRequestEvent] instance.
  RevenueCatWebhookRequestEvent({
    required this.id,

    required this.type,

    this.appUserId,

    this.environment,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final String type;

  @JsonKey(name: r'app_user_id', required: false, includeIfNull: false)
  final String? appUserId;

  @JsonKey(name: r'environment', required: false, includeIfNull: false)
  final String? environment;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RevenueCatWebhookRequestEvent &&
            runtimeType == other.runtimeType &&
            equals(
              [id, type, appUserId, environment],
              [other.id, other.type, other.appUserId, other.environment],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([id, type, appUserId, environment]);

  factory RevenueCatWebhookRequestEvent.fromJson(Map<String, dynamic> json) =>
      _$RevenueCatWebhookRequestEventFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueCatWebhookRequestEventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
