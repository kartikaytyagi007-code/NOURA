//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Input form of CalculationSex. `declined` stores \"no value\" (the profile then reads null) and yields an energy range instead of a single target. It exists so a client can clear a previously given value explicitly; JSON null is not used in requests.
enum CalculationSexInput {
  @JsonValue(r'female')
  female(r'female'),
  @JsonValue(r'male')
  male(r'male'),
  @JsonValue(r'declined')
  declined(r'declined');

  const CalculationSexInput(this.value);

  final String value;

  @override
  String toString() => value;
}
