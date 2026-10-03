//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Provisional vocabulary (D-020). Foods the user does not eat for non-allergy reasons.
enum ExclusionTag {
  @JsonValue(r'beef')
  beef(r'beef'),
  @JsonValue(r'pork')
  pork(r'pork'),
  @JsonValue(r'mutton')
  mutton(r'mutton'),
  @JsonValue(r'chicken')
  chicken(r'chicken'),
  @JsonValue(r'seafood')
  seafood(r'seafood'),
  @JsonValue(r'onion_garlic')
  onionGarlic(r'onion_garlic'),
  @JsonValue(r'root_vegetables')
  rootVegetables(r'root_vegetables'),
  @JsonValue(r'mushroom')
  mushroom(r'mushroom'),
  @JsonValue(r'alcohol')
  alcohol(r'alcohol');

  const ExclusionTag(this.value);

  final String value;

  @override
  String toString() => value;
}
