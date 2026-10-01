//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum CookingTime {
  @JsonValue(r'minimal')
  minimal(r'minimal'),
  @JsonValue(r'moderate')
  moderate(r'moderate'),
  @JsonValue(r'flexible')
  flexible(r'flexible');

  const CookingTime(this.value);

  final String value;

  @override
  String toString() => value;
}
