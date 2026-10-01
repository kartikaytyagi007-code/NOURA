//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum Uncertainty {
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'high')
  high(r'high');

  const Uncertainty(this.value);

  final String value;

  @override
  String toString() => value;
}
