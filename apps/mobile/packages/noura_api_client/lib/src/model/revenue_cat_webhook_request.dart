//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/revenue_cat_webhook_request_event.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'revenue_cat_webhook_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RevenueCatWebhookRequest {
  /// Returns a new [RevenueCatWebhookRequest] instance.
  RevenueCatWebhookRequest({this.apiVersion, required this.event});

  @JsonKey(name: r'api_version', required: false, includeIfNull: false)
  final String? apiVersion;

  @JsonKey(name: r'event', required: true, includeIfNull: false)
  final RevenueCatWebhookRequestEvent event;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RevenueCatWebhookRequest &&
            runtimeType == other.runtimeType &&
            equals([apiVersion, event], [other.apiVersion, other.event]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([apiVersion, event]);

  factory RevenueCatWebhookRequest.fromJson(Map<String, dynamic> json) =>
      _$RevenueCatWebhookRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueCatWebhookRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
