//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/confirmed_item_input.dart';
import 'package:noura_api_client/src/model/meal_slot.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'patch_meal_log_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchMealLogRequest {
  /// Returns a new [PatchMealLogRequest] instance.
  PatchMealLogRequest({
    required this.expectedRevision,

    this.consumedAt,

    this.slot,

    this.items,
  });

  // minimum: 1
  @JsonKey(name: r'expected_revision', required: true, includeIfNull: false)
  final int expectedRevision;

  @JsonKey(name: r'consumed_at', required: false, includeIfNull: false)
  final DateTime? consumedAt;

  @JsonKey(name: r'slot', required: false, includeIfNull: false)
  final MealSlot? slot;

  @JsonKey(name: r'items', required: false, includeIfNull: false)
  final List<ConfirmedItemInput>? items;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PatchMealLogRequest &&
            runtimeType == other.runtimeType &&
            equals(
              [expectedRevision, consumedAt, slot, items],
              [
                other.expectedRevision,
                other.consumedAt,
                other.slot,
                other.items,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([expectedRevision, consumedAt, slot, items]);

  factory PatchMealLogRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchMealLogRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PatchMealLogRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
