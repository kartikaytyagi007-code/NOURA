//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DietType {
  @JsonValue(r'vegetarian')
  vegetarian(r'vegetarian'),
  @JsonValue(r'eggatarian')
  eggatarian(r'eggatarian'),
  @JsonValue(r'vegan')
  vegan(r'vegan'),
  @JsonValue(r'non_vegetarian')
  nonVegetarian(r'non_vegetarian');

  const DietType(this.value);

  final String value;

  @override
  String toString() => value;
}
