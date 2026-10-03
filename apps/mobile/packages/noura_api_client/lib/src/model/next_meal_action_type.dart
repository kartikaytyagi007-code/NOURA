//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum NextMealActionType {
  @JsonValue(r'add')
  add(r'add'),
  @JsonValue(r'swap')
  swap(r'swap'),
  @JsonValue(r'dismiss')
  dismiss(r'dismiss');

  const NextMealActionType(this.value);

  final String value;

  @override
  String toString() => value;
}
