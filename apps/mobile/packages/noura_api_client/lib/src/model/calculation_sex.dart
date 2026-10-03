//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Optional parameter for energy equations only. Not gender identity.
enum CalculationSex {
  @JsonValue(r'female')
  female(r'female'),
  @JsonValue(r'male')
  male(r'male');

  const CalculationSex(this.value);

  final String value;

  @override
  String toString() => value;
}
