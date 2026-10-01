//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/error_code.dart';
import 'package:noura_api_client/src/model/field_error.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'error_body.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ErrorBody {
  /// Returns a new [ErrorBody] instance.
  ErrorBody({
    required this.code,

    required this.message,

    required this.fieldErrors,

    required this.retryable,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final ErrorCode code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'field_errors', required: true, includeIfNull: false)
  final List<FieldError> fieldErrors;

  @JsonKey(name: r'retryable', required: true, includeIfNull: false)
  final bool retryable;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ErrorBody &&
            runtimeType == other.runtimeType &&
            equals(
              [code, message, fieldErrors, retryable],
              [other.code, other.message, other.fieldErrors, other.retryable],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([code, message, fieldErrors, retryable]);

  factory ErrorBody.fromJson(Map<String, dynamic> json) =>
      _$ErrorBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorBodyToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
