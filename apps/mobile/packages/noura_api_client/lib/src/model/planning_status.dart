//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// requested: a generation request exists (poll `GET /v1/jobs/{id}`). unavailable_tracking_only / unavailable_needs_review: eligibility excludes automated plans. unavailable_policy: eligible, but no approved target policy is configured for this environment.
enum PlanningStatus {
  @JsonValue(r'requested')
  requested(r'requested'),
  @JsonValue(r'unavailable_tracking_only')
  unavailableTrackingOnly(r'unavailable_tracking_only'),
  @JsonValue(r'unavailable_needs_review')
  unavailableNeedsReview(r'unavailable_needs_review'),
  @JsonValue(r'unavailable_policy')
  unavailablePolicy(r'unavailable_policy');

  const PlanningStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
