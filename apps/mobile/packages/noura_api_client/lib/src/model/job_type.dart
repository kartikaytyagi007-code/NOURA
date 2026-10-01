//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum JobType {
  @JsonValue(r'diet_plan')
  dietPlan(r'diet_plan'),
  @JsonValue(r'workout_plan')
  workoutPlan(r'workout_plan'),
  @JsonValue(r'plan_regeneration')
  planRegeneration(r'plan_regeneration'),
  @JsonValue(r'meal_scan')
  mealScan(r'meal_scan'),
  @JsonValue(r'coach_reply')
  coachReply(r'coach_reply'),
  @JsonValue(r'weekly_insight')
  weeklyInsight(r'weekly_insight');

  const JobType(this.value);

  final String value;

  @override
  String toString() => value;
}
