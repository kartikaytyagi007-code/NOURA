// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plate_fixes.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlateFixesCWProxy {
  PlateFixes scanId(String scanId);

  PlateFixes revision(int revision);

  PlateFixes fixes(List<PlateAction> fixes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlateFixes(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlateFixes(...).copyWith(id: 12, name: "My name")
  /// ````
  PlateFixes call({String scanId, int revision, List<PlateAction> fixes});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlateFixes.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlateFixes.copyWith.fieldName(...)`
class _$PlateFixesCWProxyImpl implements _$PlateFixesCWProxy {
  const _$PlateFixesCWProxyImpl(this._value);

  final PlateFixes _value;

  @override
  PlateFixes scanId(String scanId) => this(scanId: scanId);

  @override
  PlateFixes revision(int revision) => this(revision: revision);

  @override
  PlateFixes fixes(List<PlateAction> fixes) => this(fixes: fixes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PlateFixes(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PlateFixes(...).copyWith(id: 12, name: "My name")
  /// ````
  PlateFixes call({
    Object? scanId = const $CopyWithPlaceholder(),
    Object? revision = const $CopyWithPlaceholder(),
    Object? fixes = const $CopyWithPlaceholder(),
  }) {
    return PlateFixes(
      scanId: scanId == const $CopyWithPlaceholder()
          ? _value.scanId
          // ignore: cast_nullable_to_non_nullable
          : scanId as String,
      revision: revision == const $CopyWithPlaceholder()
          ? _value.revision
          // ignore: cast_nullable_to_non_nullable
          : revision as int,
      fixes: fixes == const $CopyWithPlaceholder()
          ? _value.fixes
          // ignore: cast_nullable_to_non_nullable
          : fixes as List<PlateAction>,
    );
  }
}

extension $PlateFixesCopyWith on PlateFixes {
  /// Returns a callable class that can be used as follows: `instanceOfPlateFixes.copyWith(...)` or like so:`instanceOfPlateFixes.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlateFixesCWProxy get copyWith => _$PlateFixesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlateFixes _$PlateFixesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PlateFixes', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['scan_id', 'revision', 'fixes']);
      final val = PlateFixes(
        scanId: $checkedConvert('scan_id', (v) => v as String),
        revision: $checkedConvert('revision', (v) => (v as num).toInt()),
        fixes: $checkedConvert(
          'fixes',
          (v) => (v as List<dynamic>)
              .map((e) => PlateAction.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'scanId': 'scan_id'});

Map<String, dynamic> _$PlateFixesToJson(PlateFixes instance) =>
    <String, dynamic>{
      'scan_id': instance.scanId,
      'revision': instance.revision,
      'fixes': instance.fixes.map((e) => e.toJson()).toList(),
    };
