//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/food.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'food_list.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FoodList {
  /// Returns a new [FoodList] instance.
  FoodList({required this.items, required this.nextCursor});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<Food> items;

  @JsonKey(name: r'next_cursor', required: true, includeIfNull: true)
  final String? nextCursor;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FoodList &&
            runtimeType == other.runtimeType &&
            equals([items, nextCursor], [other.items, other.nextCursor]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([items, nextCursor]);

  factory FoodList.fromJson(Map<String, dynamic> json) =>
      _$FoodListFromJson(json);

  Map<String, dynamic> toJson() => _$FoodListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
