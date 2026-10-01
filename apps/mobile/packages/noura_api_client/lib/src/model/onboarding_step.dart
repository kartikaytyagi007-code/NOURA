//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum OnboardingStep {
  @JsonValue(r'basics')
  basics(r'basics'),
  @JsonValue(r'goals')
  goals(r'goals'),
  @JsonValue(r'diet')
  diet(r'diet'),
  @JsonValue(r'training')
  training(r'training'),
  @JsonValue(r'eligibility')
  eligibility(r'eligibility'),
  @JsonValue(r'review')
  review(r'review');

  const OnboardingStep(this.value);

  final String value;

  @override
  String toString() => value;
}
