//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum GoalType {
  @JsonValue(r'lose_fat')
  loseFat(r'lose_fat'),
  @JsonValue(r'maintain')
  maintain(r'maintain'),
  @JsonValue(r'gain_muscle')
  gainMuscle(r'gain_muscle'),
  @JsonValue(r'general_health')
  generalHealth(r'general_health');

  const GoalType(this.value);

  final String value;

  @override
  String toString() => value;
}
