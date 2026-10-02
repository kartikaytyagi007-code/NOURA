//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:noura_api_client/src/model/after_changes_scenario.dart';
import 'package:noura_api_client/src/model/plate_action.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'plate_fixes.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlateFixes {
  /// Returns a new [PlateFixes] instance.
  PlateFixes({
    required this.scanId,

    required this.revision,

    required this.fixes,

    required this.afterChanges,
  });

  @JsonKey(name: r'scan_id', required: true, includeIfNull: false)
  final String scanId;

  // minimum: 1
  @JsonKey(name: r'revision', required: true, includeIfNull: false)
  final int revision;

  @JsonKey(name: r'fixes', required: true, includeIfNull: false)
  final List<PlateAction> fixes;

  @JsonKey(name: r'after_changes', required: true, includeIfNull: false)
  final AfterChangesScenario afterChanges;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PlateFixes &&
            runtimeType == other.runtimeType &&
            equals(
              [scanId, revision, fixes, afterChanges],
              [other.scanId, other.revision, other.fixes, other.afterChanges],
            );
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      mapPropsToHashCode([scanId, revision, fixes, afterChanges]);

  factory PlateFixes.fromJson(Map<String, dynamic> json) =>
      _$PlateFixesFromJson(json);

  Map<String, dynamic> toJson() => _$PlateFixesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
