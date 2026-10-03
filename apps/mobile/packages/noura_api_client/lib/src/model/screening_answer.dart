//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ScreeningAnswer {
  @JsonValue(r'yes')
  yes(r'yes'),
  @JsonValue(r'no')
  no(r'no'),
  @JsonValue(r'prefer_not_to_say')
  preferNotToSay(r'prefer_not_to_say');

  const ScreeningAnswer(this.value);

  final String value;

  @override
  String toString() => value;
}
