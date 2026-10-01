//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ErrorCode {
  @JsonValue(r'VALIDATION_ERROR')
  VALIDATION_ERROR(r'VALIDATION_ERROR'),
  @JsonValue(r'UNAUTHENTICATED')
  UNAUTHENTICATED(r'UNAUTHENTICATED'),
  @JsonValue(r'NOT_FOUND')
  NOT_FOUND(r'NOT_FOUND'),
  @JsonValue(r'REVISION_CONFLICT')
  REVISION_CONFLICT(r'REVISION_CONFLICT'),
  @JsonValue(r'QUOTA_EXCEEDED')
  QUOTA_EXCEEDED(r'QUOTA_EXCEEDED'),
  @JsonValue(r'PROVIDER_UNAVAILABLE')
  PROVIDER_UNAVAILABLE(r'PROVIDER_UNAVAILABLE'),
  @JsonValue(r'UNSUPPORTED_INPUT')
  UNSUPPORTED_INPUT(r'UNSUPPORTED_INPUT'),
  @JsonValue(r'CONSTRAINT_CONFLICT')
  CONSTRAINT_CONFLICT(r'CONSTRAINT_CONFLICT'),
  @JsonValue(r'INTERNAL_ERROR')
  INTERNAL_ERROR(r'INTERNAL_ERROR');

  const ErrorCode(this.value);

  final String value;

  @override
  String toString() => value;
}
