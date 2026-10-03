//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ConsentType {
  @JsonValue(r'terms')
  terms(r'terms'),
  @JsonValue(r'privacy')
  privacy(r'privacy'),
  @JsonValue(r'health_data_processing')
  healthDataProcessing(r'health_data_processing'),
  @JsonValue(r'ai_meal_processing')
  aiMealProcessing(r'ai_meal_processing'),
  @JsonValue(r'progress_photo_storage')
  progressPhotoStorage(r'progress_photo_storage');

  const ConsentType(this.value);

  final String value;

  @override
  String toString() => value;
}
