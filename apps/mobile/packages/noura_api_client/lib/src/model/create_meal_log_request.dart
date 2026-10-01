//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/confirmed_item_input.dart';
import 'package:noura_api_client/src/model/meal_slot.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'create_meal_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateMealLogRequest {
  /// Returns a new [CreateMealLogRequest] instance.
  CreateMealLogRequest({
    required this.clientId,

    required this.consumedAt,

    required this.timezone,

    required this.slot,

    this.scanId,

    this.planMealId,

    required this.items,
  });

  @JsonKey(name: r'client_id', required: true, includeIfNull: false)
  final String clientId;

  @JsonKey(name: r'consumed_at', required: true, includeIfNull: false)
  final DateTime consumedAt;

  @JsonKey(name: r'timezone', required: true, includeIfNull: false)
  final String timezone;

  @JsonKey(name: r'slot', required: true, includeIfNull: false)
  final MealSlot slot;

  @JsonKey(name: r'scan_id', required: false, includeIfNull: false)
  final String? scanId;

  @JsonKey(name: r'plan_meal_id', required: false, includeIfNull: false)
  final String? planMealId;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ConfirmedItemInput> items;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CreateMealLogRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [clientId, consumedAt, timezone, slot, scanId, planMealId, items],
              [
                other.clientId,
                other.consumedAt,
                other.timezone,
                other.slot,
                other.scanId,
                other.planMealId,
                other.items,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        clientId,
        consumedAt,
        timezone,
        slot,
        scanId,
        planMealId,
        items,
      ]);

  factory CreateMealLogRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMealLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMealLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
