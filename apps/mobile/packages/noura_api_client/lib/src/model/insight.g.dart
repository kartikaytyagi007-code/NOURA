// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InsightCWProxy {
  Insight key(String key);

  Insight evidence(Map<String, Object> evidence);

  Insight explanation(String? explanation);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Insight(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Insight(...).copyWith(id: 12, name: "My name")
  /// ````
  Insight call({String key, Map<String, Object> evidence, String? explanation});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInsight.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInsight.copyWith.fieldName(...)`
class _$InsightCWProxyImpl implements _$InsightCWProxy {
  const _$InsightCWProxyImpl(this._value);

  final Insight _value;

  @override
  Insight key(String key) => this(key: key);

  @override
  Insight evidence(Map<String, Object> evidence) => this(evidence: evidence);

  @override
  Insight explanation(String? explanation) => this(explanation: explanation);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Insight(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Insight(...).copyWith(id: 12, name: "My name")
  /// ````
  Insight call({
    Object? key = const $CopyWithPlaceholder(),
    Object? evidence = const $CopyWithPlaceholder(),
    Object? explanation = const $CopyWithPlaceholder(),
  }) {
    return Insight(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      evidence: evidence == const $CopyWithPlaceholder()
          ? _value.evidence
          // ignore: cast_nullable_to_non_nullable
          : evidence as Map<String, Object>,
      explanation: explanation == const $CopyWithPlaceholder()
          ? _value.explanation
          // ignore: cast_nullable_to_non_nullable
          : explanation as String?,
    );
  }
}

extension $InsightCopyWith on Insight {
  /// Returns a callable class that can be used as follows: `instanceOfInsight.copyWith(...)` or like so:`instanceOfInsight.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InsightCWProxy get copyWith => _$InsightCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Insight _$InsightFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Insight',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['key', 'evidence', 'explanation']);
    final val = Insight(
      key: $checkedConvert('key', (v) => v as String),
      evidence: $checkedConvert(
        'evidence',
        (v) =>
            (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
      ),
      explanation: $checkedConvert('explanation', (v) => v as String?),
    );
    return val;
  },
);

Map<String, dynamic> _$InsightToJson(Insight instance) => <String, dynamic>{
  'key': instance.key,
  'evidence': instance.evidence,
  'explanation': instance.explanation,
};
