//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'safe_error.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SafeError {
  /// Returns a new [SafeError] instance.
  SafeError({required this.code, required this.message});

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SafeError &&
            runtimeType == other.runtimeType &&
            equals([code, message], [other.code, other.message]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([code, message]);

  factory SafeError.fromJson(Map<String, dynamic> json) =>
      _$SafeErrorFromJson(json);

  Map<String, dynamic> toJson() => _$SafeErrorToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
