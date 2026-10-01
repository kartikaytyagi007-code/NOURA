//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/projected_scenario.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'plate_action.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlateAction {
  /// Returns a new [PlateAction] instance.
  PlateAction({
    required this.type,

    required this.itemId,

    required this.catalogFoodId,

    required this.proposedGrams,

    required this.reason,

    required this.projected,

    required this.requiresConfirmation,
  });

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final PlateActionTypeEnum type;

  @JsonKey(name: r'item_id', required: true, includeIfNull: true)
  final String? itemId;

  @JsonKey(name: r'catalog_food_id', required: true, includeIfNull: true)
  final String? catalogFoodId;

  // minimum: 0
  @JsonKey(name: r'proposed_grams', required: true, includeIfNull: true)
  final num? proposedGrams;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'projected', required: true, includeIfNull: false)
  final ProjectedScenario projected;

  /// Always true; a fix never applies without user confirmation.
  @JsonKey(name: r'requires_confirmation', required: true, includeIfNull: false)
  final bool requiresConfirmation;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlateAction &&
            runtimeType == other.runtimeType &&
            equals(
              [
                type,
                itemId,
                catalogFoodId,
                proposedGrams,
                reason,
                projected,
                requiresConfirmation,
              ],
              [
                other.type,
                other.itemId,
                other.catalogFoodId,
                other.proposedGrams,
                other.reason,
                other.projected,
                other.requiresConfirmation,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([
        type,
        itemId,
        catalogFoodId,
        proposedGrams,
        reason,
        projected,
        requiresConfirmation,
      ]);

  factory PlateAction.fromJson(Map<String, dynamic> json) =>
      _$PlateActionFromJson(json);

  Map<String, dynamic> toJson() => _$PlateActionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PlateActionTypeEnum {
  @JsonValue(r'keep')
  keep(r'keep'),
  @JsonValue(r'reduce')
  reduce(r'reduce'),
  @JsonValue(r'add')
  add(r'add'),
  @JsonValue(r'replace')
  replace(r'replace');

  const PlateActionTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
