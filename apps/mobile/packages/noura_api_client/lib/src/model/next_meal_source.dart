//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// plan means this option fills an existing slot in the active diet plan (swap-able); catalog means a standalone suggestion.
enum NextMealSource {
  @JsonValue(r'plan')
  plan(r'plan'),
  @JsonValue(r'catalog')
  catalog(r'catalog');

  const NextMealSource(this.value);

  final String value;

  @override
  String toString() => value;
}
