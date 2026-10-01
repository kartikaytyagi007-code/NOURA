//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'coach_card.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoachCard {
  /// Returns a new [CoachCard] instance.
  CoachCard({required this.type, required this.title, required this.refId});

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final CoachCardTypeEnum type;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'ref_id', required: true, includeIfNull: true)
  final String? refId;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CoachCard &&
            runtimeType == other.runtimeType &&
            equals(
              [type, title, refId],
              [other.type, other.title, other.refId],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([type, title, refId]);

  factory CoachCard.fromJson(Map<String, dynamic> json) =>
      _$CoachCardFromJson(json);

  Map<String, dynamic> toJson() => _$CoachCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum CoachCardTypeEnum {
  @JsonValue(r'meal')
  meal(r'meal'),
  @JsonValue(r'workout')
  workout(r'workout'),
  @JsonValue(r'insight')
  insight(r'insight');

  const CoachCardTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
