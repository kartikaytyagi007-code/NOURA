//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Provisional vocabulary (D-020). Areas where exercises should be gentler; not a medical assessment.
enum LimitationTag {
  @JsonValue(r'knee')
  knee(r'knee'),
  @JsonValue(r'lower_back')
  lowerBack(r'lower_back'),
  @JsonValue(r'shoulder')
  shoulder(r'shoulder'),
  @JsonValue(r'neck')
  neck(r'neck'),
  @JsonValue(r'wrist_elbow')
  wristElbow(r'wrist_elbow'),
  @JsonValue(r'hip')
  hip(r'hip'),
  @JsonValue(r'ankle_foot')
  ankleFoot(r'ankle_foot');

  const LimitationTag(this.value);

  final String value;

  @override
  String toString() => value;
}
