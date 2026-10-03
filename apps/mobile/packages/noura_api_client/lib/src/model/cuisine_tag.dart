//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Provisional vocabulary (D-020).
enum CuisineTag {
  @JsonValue(r'north_indian')
  northIndian(r'north_indian'),
  @JsonValue(r'south_indian')
  southIndian(r'south_indian'),
  @JsonValue(r'east_indian')
  eastIndian(r'east_indian'),
  @JsonValue(r'west_indian')
  westIndian(r'west_indian'),
  @JsonValue(r'indo_chinese')
  indoChinese(r'indo_chinese'),
  @JsonValue(r'continental')
  continental(r'continental');

  const CuisineTag(this.value);

  final String value;

  @override
  String toString() => value;
}
