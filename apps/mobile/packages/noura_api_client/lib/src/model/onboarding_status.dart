//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum OnboardingStatus {
  @JsonValue(r'not_started')
  notStarted(r'not_started'),
  @JsonValue(r'in_progress')
  inProgress(r'in_progress'),
  @JsonValue(r'completed')
  completed(r'completed');

  const OnboardingStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
