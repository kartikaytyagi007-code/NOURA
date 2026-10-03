// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognition.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecognitionCWProxy {
  Recognition schemaVersion(RecognitionSchemaVersionEnum schemaVersion);

  Recognition imageIsFood(bool imageIsFood);

  Recognition quality(RecognitionQualityEnum quality);

  Recognition items(List<RecognitionItem> items);

  Recognition clarification(String? clarification);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Recognition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Recognition(...).copyWith(id: 12, name: "My name")
  /// ````
  Recognition call({
    RecognitionSchemaVersionEnum schemaVersion,
    bool imageIsFood,
    RecognitionQualityEnum quality,
    List<RecognitionItem> items,
    String? clarification,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecognition.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecognition.copyWith.fieldName(...)`
class _$RecognitionCWProxyImpl implements _$RecognitionCWProxy {
  const _$RecognitionCWProxyImpl(this._value);

  final Recognition _value;

  @override
  Recognition schemaVersion(RecognitionSchemaVersionEnum schemaVersion) =>
      this(schemaVersion: schemaVersion);

  @override
  Recognition imageIsFood(bool imageIsFood) => this(imageIsFood: imageIsFood);

  @override
  Recognition quality(RecognitionQualityEnum quality) => this(quality: quality);

  @override
  Recognition items(List<RecognitionItem> items) => this(items: items);

  @override
  Recognition clarification(String? clarification) =>
      this(clarification: clarification);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Recognition(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Recognition(...).copyWith(id: 12, name: "My name")
  /// ````
  Recognition call({
    Object? schemaVersion = const $CopyWithPlaceholder(),
    Object? imageIsFood = const $CopyWithPlaceholder(),
    Object? quality = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
    Object? clarification = const $CopyWithPlaceholder(),
  }) {
    return Recognition(
      schemaVersion: schemaVersion == const $CopyWithPlaceholder()
          ? _value.schemaVersion
          // ignore: cast_nullable_to_non_nullable
          : schemaVersion as RecognitionSchemaVersionEnum,
      imageIsFood: imageIsFood == const $CopyWithPlaceholder()
          ? _value.imageIsFood
          // ignore: cast_nullable_to_non_nullable
          : imageIsFood as bool,
      quality: quality == const $CopyWithPlaceholder()
          ? _value.quality
          // ignore: cast_nullable_to_non_nullable
          : quality as RecognitionQualityEnum,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<RecognitionItem>,
      clarification: clarification == const $CopyWithPlaceholder()
          ? _value.clarification
          // ignore: cast_nullable_to_non_nullable
          : clarification as String?,
    );
  }
}

extension $RecognitionCopyWith on Recognition {
  /// Returns a callable class that can be used as follows: `instanceOfRecognition.copyWith(...)` or like so:`instanceOfRecognition.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecognitionCWProxy get copyWith => _$RecognitionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recognition _$RecognitionFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Recognition',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'schema_version',
        'image_is_food',
        'quality',
        'items',
        'clarification',
      ],
    );
    final val = Recognition(
      schemaVersion: $checkedConvert(
        'schema_version',
        (v) => $enumDecode(_$RecognitionSchemaVersionEnumEnumMap, v),
      ),
      imageIsFood: $checkedConvert('image_is_food', (v) => v as bool),
      quality: $checkedConvert(
        'quality',
        (v) => $enumDecode(_$RecognitionQualityEnumEnumMap, v),
      ),
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map((e) => RecognitionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      clarification: $checkedConvert('clarification', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'schemaVersion': 'schema_version',
    'imageIsFood': 'image_is_food',
  },
);

Map<String, dynamic> _$RecognitionToJson(Recognition instance) =>
    <String, dynamic>{
      'schema_version':
          _$RecognitionSchemaVersionEnumEnumMap[instance.schemaVersion]!,
      'image_is_food': instance.imageIsFood,
      'quality': _$RecognitionQualityEnumEnumMap[instance.quality]!,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'clarification': instance.clarification,
    };

const _$RecognitionSchemaVersionEnumEnumMap = {
  RecognitionSchemaVersionEnum.n1: '1',
};

const _$RecognitionQualityEnumEnumMap = {
  RecognitionQualityEnum.usable: 'usable',
  RecognitionQualityEnum.blurry: 'blurry',
  RecognitionQualityEnum.tooDark: 'too_dark',
  RecognitionQualityEnum.ambiguous: 'ambiguous',
  RecognitionQualityEnum.unusable: 'unusable',
};
