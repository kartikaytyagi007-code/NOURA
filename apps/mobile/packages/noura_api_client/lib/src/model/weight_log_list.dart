//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/weight_log.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'weight_log_list.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeightLogList {
  /// Returns a new [WeightLogList] instance.
  WeightLogList({required this.items, required this.nextCursor});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<WeightLog> items;

  @JsonKey(name: r'next_cursor', required: true, includeIfNull: true)
  final String? nextCursor;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WeightLogList &&
            runtimeType == other.runtimeType &&
            equals([items, nextCursor], [other.items, other.nextCursor]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([items, nextCursor]);

  factory WeightLogList.fromJson(Map<String, dynamic> json) =>
      _$WeightLogListFromJson(json);

  Map<String, dynamic> toJson() => _$WeightLogListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
