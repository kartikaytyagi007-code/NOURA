//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'exercise_ref.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExerciseRef {
  /// Returns a new [ExerciseRef] instance.
  ExerciseRef({required this.id, required this.name});

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExerciseRef &&
            runtimeType == other.runtimeType &&
            equals([id, name], [other.id, other.name]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([id, name]);

  factory ExerciseRef.fromJson(Map<String, dynamic> json) =>
      _$ExerciseRefFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseRefToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
