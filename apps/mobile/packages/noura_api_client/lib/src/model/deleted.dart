//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'deleted.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Deleted {
  /// Returns a new [Deleted] instance.
  Deleted({required this.id, required this.deleted});

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'deleted', required: true, includeIfNull: false)
  final bool deleted;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Deleted &&
            runtimeType == other.runtimeType &&
            equals([id, deleted], [other.id, other.deleted]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([id, deleted]);

  factory Deleted.fromJson(Map<String, dynamic> json) =>
      _$DeletedFromJson(json);

  Map<String, dynamic> toJson() => _$DeletedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
