//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/confirmed_item_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'confirm_items_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmItemsRequest {
  /// Returns a new [ConfirmItemsRequest] instance.
  ConfirmItemsRequest({required this.expectedRevision, required this.items});

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ConfirmedItemInput> items;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ConfirmItemsRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [expectedRevision, items],
              [other.expectedRevision, other.items],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([expectedRevision, items]);

  factory ConfirmItemsRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfirmItemsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmItemsRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
