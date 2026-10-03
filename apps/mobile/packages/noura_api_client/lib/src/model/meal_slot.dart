//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum MealSlot {
  @JsonValue(r'breakfast')
  breakfast(r'breakfast'),
  @JsonValue(r'lunch')
  lunch(r'lunch'),
  @JsonValue(r'dinner')
  dinner(r'dinner'),
  @JsonValue(r'snack')
  snack(r'snack');

  const MealSlot(this.value);

  final String value;

  @override
  String toString() => value;
}
