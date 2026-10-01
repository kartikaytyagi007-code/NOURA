//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/oil_level.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'preparation_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreparationInput {
  /// Returns a new [PreparationInput] instance.
  PreparationInput({this.method, this.oilLevel, this.source_});

  @JsonKey(name: r'method', required: false, includeIfNull: false)
  final String? method;

  @JsonKey(name: r'oil_level', required: false, includeIfNull: false)
  final OilLevel? oilLevel;

  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final PreparationInputSource_Enum? source_;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PreparationInput &&
            runtimeType == other.runtimeType &&
            equals(
              [method, oilLevel, source_],
              [other.method, other.oilLevel, other.source_],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([method, oilLevel, source_]);

  factory PreparationInput.fromJson(Map<String, dynamic> json) =>
      _$PreparationInputFromJson(json);

  Map<String, dynamic> toJson() => _$PreparationInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PreparationInputSource_Enum {
  @JsonValue(r'homemade')
  homemade(r'homemade'),
  @JsonValue(r'restaurant')
  restaurant(r'restaurant'),
  @JsonValue(r'packaged')
  packaged(r'packaged'),
  @JsonValue(r'unknown')
  unknown(r'unknown');

  const PreparationInputSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
