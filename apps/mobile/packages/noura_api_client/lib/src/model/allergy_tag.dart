//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Provisional vocabulary (docs/decisions.md D-020). Not a medical allergy list.
enum AllergyTag {
  @JsonValue(r'gluten')
  gluten(r'gluten'),
  @JsonValue(r'crustacean')
  crustacean(r'crustacean'),
  @JsonValue(r'milk')
  milk(r'milk'),
  @JsonValue(r'egg')
  egg(r'egg'),
  @JsonValue(r'fish')
  fish(r'fish'),
  @JsonValue(r'peanut')
  peanut(r'peanut'),
  @JsonValue(r'tree_nut')
  treeNut(r'tree_nut'),
  @JsonValue(r'soy')
  soy(r'soy'),
  @JsonValue(r'sesame')
  sesame(r'sesame');

  const AllergyTag(this.value);

  final String value;

  @override
  String toString() => value;
}
