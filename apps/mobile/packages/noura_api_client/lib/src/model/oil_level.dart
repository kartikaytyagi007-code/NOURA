//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum OilLevel {
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'light')
  light(r'light'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'heavy')
  heavy(r'heavy'),
  @JsonValue(r'unknown')
  unknown(r'unknown');

  const OilLevel(this.value);

  final String value;

  @override
  String toString() => value;
}
