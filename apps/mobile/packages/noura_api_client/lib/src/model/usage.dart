//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/feature_usage.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'usage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Usage {
  /// Returns a new [Usage] instance.
  Usage({required this.timezone, required this.features});

  @JsonKey(name: r'timezone', required: true, includeIfNull: false)
  final String timezone;

  @JsonKey(name: r'features', required: true, includeIfNull: false)
  final List<FeatureUsage> features;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Usage &&
            runtimeType == other.runtimeType &&
            equals([timezone, features], [other.timezone, other.features]);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ mapPropsToHashCode([timezone, features]);

  factory Usage.fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);

  Map<String, dynamic> toJson() => _$UsageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
