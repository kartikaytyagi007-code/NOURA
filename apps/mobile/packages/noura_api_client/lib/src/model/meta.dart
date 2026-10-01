//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'meta.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Meta {
  /// Returns a new [Meta] instance.
  Meta({required this.requestId});

  @JsonKey(name: r'request_id', required: true, includeIfNull: false)
  final String requestId;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Meta &&
            runtimeType == other.runtimeType &&
            equals([requestId], [other.requestId]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([requestId]);

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
