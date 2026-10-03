//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'set_log_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetLogInput {
  /// Returns a new [SetLogInput] instance.
  SetLogInput({
    required this.exerciseId,

    required this.setOrdinal,

    required this.reps,

    required this.loadKg,

    required this.skipped,
  });

  @JsonKey(name: r'exercise_id', required: true, includeIfNull: false)
  final String exerciseId;

  // minimum: 1
  // maximum: 50
  @JsonKey(name: r'set_ordinal', required: true, includeIfNull: false)
  final int setOrdinal;

  // minimum: 0
  // maximum: 500
  @JsonKey(name: r'reps', required: true, includeIfNull: true)
  final int? reps;

  // minimum: 0
  // maximum: 1000
  @JsonKey(name: r'load_kg', required: true, includeIfNull: true)
  final num? loadKg;

  @JsonKey(name: r'skipped', required: true, includeIfNull: false)
  final bool skipped;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SetLogInput &&
            runtimeType == other.runtimeType &&
            equals(
              [exerciseId, setOrdinal, reps, loadKg, skipped],
              [
                other.exerciseId,
                other.setOrdinal,
                other.reps,
                other.loadKg,
                other.skipped,
              ],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([exerciseId, setOrdinal, reps, loadKg, skipped]);

  factory SetLogInput.fromJson(Map<String, dynamic> json) =>
      _$SetLogInputFromJson(json);

  Map<String, dynamic> toJson() => _$SetLogInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
