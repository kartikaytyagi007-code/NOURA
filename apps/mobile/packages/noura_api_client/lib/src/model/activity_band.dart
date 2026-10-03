//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ActivityBand {
  @JsonValue(r'sedentary')
  sedentary(r'sedentary'),
  @JsonValue(r'light')
  light(r'light'),
  @JsonValue(r'moderate')
  moderate(r'moderate'),
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'very_active')
  veryActive(r'very_active');

  const ActivityBand(this.value);

  final String value;

  @override
  String toString() => value;
}
