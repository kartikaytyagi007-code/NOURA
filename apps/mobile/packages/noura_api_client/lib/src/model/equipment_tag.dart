//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Provisional vocabulary (D-020); refined with the exercise catalog in M7.
enum EquipmentTag {
  @JsonValue(r'bodyweight')
  bodyweight(r'bodyweight'),
  @JsonValue(r'dumbbells')
  dumbbells(r'dumbbells'),
  @JsonValue(r'barbell')
  barbell(r'barbell'),
  @JsonValue(r'kettlebell')
  kettlebell(r'kettlebell'),
  @JsonValue(r'resistance_bands')
  resistanceBands(r'resistance_bands'),
  @JsonValue(r'bench')
  bench(r'bench'),
  @JsonValue(r'pull_up_bar')
  pullUpBar(r'pull_up_bar'),
  @JsonValue(r'machines')
  machines(r'machines');

  const EquipmentTag(this.value);

  final String value;

  @override
  String toString() => value;
}
