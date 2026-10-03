// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InsightSummaryCWProxy {
  InsightSummary key(String key);

  InsightSummary text(String text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InsightSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InsightSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  InsightSummary call({String key, String text});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInsightSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInsightSummary.copyWith.fieldName(...)`
class _$InsightSummaryCWProxyImpl implements _$InsightSummaryCWProxy {
  const _$InsightSummaryCWProxyImpl(this._value);

  final InsightSummary _value;

  @override
  InsightSummary key(String key) => this(key: key);

  @override
  InsightSummary text(String text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InsightSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InsightSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  InsightSummary call({
    Object? key = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
  }) {
    return InsightSummary(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String,
    );
  }
}

extension $InsightSummaryCopyWith on InsightSummary {
  /// Returns a callable class that can be used as follows: `instanceOfInsightSummary.copyWith(...)` or like so:`instanceOfInsightSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InsightSummaryCWProxy get copyWith => _$InsightSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsightSummary _$InsightSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InsightSummary', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['key', 'text']);
      final val = InsightSummary(
        key: $checkedConvert('key', (v) => v as String),
        text: $checkedConvert('text', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$InsightSummaryToJson(InsightSummary instance) =>
    <String, dynamic>{'key': instance.key, 'text': instance.text};
