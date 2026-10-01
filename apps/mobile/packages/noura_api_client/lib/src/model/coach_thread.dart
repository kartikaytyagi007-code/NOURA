//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'coach_thread.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoachThread {
  /// Returns a new [CoachThread] instance.
  CoachThread({required this.id, required this.createdAt});

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CoachThread &&
            runtimeType == other.runtimeType &&
            equals([id, createdAt], [other.id, other.createdAt]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([id, createdAt]);

  factory CoachThread.fromJson(Map<String, dynamic> json) =>
      _$CoachThreadFromJson(json);

  Map<String, dynamic> toJson() => _$CoachThreadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
