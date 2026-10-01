//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum EligibilityStatus {
  @JsonValue(r'eligible')
  eligible(r'eligible'),
  @JsonValue(r'tracking_only')
  trackingOnly(r'tracking_only'),
  @JsonValue(r'needs_review')
  needsReview(r'needs_review');

  const EligibilityStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
