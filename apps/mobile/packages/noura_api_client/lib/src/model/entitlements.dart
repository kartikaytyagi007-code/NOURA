//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/entitlement.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'entitlements.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Entitlements {
  /// Returns a new [Entitlements] instance.
  Entitlements({required this.entitlements});

  @JsonKey(name: r'entitlements', required: true, includeIfNull: false)
  final List<Entitlement> entitlements;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Entitlements &&
            runtimeType == other.runtimeType &&
            equals([entitlements], [other.entitlements]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([entitlements]);

  factory Entitlements.fromJson(Map<String, dynamic> json) =>
      _$EntitlementsFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
