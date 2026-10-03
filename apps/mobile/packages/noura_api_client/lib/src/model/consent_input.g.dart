// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ConsentInputCWProxy {
  ConsentInput consentType(ConsentType consentType);

  ConsentInput version(String version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConsentInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConsentInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ConsentInput call({ConsentType consentType, String version});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfConsentInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfConsentInput.copyWith.fieldName(...)`
class _$ConsentInputCWProxyImpl implements _$ConsentInputCWProxy {
  const _$ConsentInputCWProxyImpl(this._value);

  final ConsentInput _value;

  @override
  ConsentInput consentType(ConsentType consentType) =>
      this(consentType: consentType);

  @override
  ConsentInput version(String version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ConsentInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ConsentInput(...).copyWith(id: 12, name: "My name")
  /// ````
  ConsentInput call({
    Object? consentType = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return ConsentInput(
      consentType: consentType == const $CopyWithPlaceholder()
          ? _value.consentType
          // ignore: cast_nullable_to_non_nullable
          : consentType as ConsentType,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as String,
    );
  }
}

extension $ConsentInputCopyWith on ConsentInput {
  /// Returns a callable class that can be used as follows: `instanceOfConsentInput.copyWith(...)` or like so:`instanceOfConsentInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ConsentInputCWProxy get copyWith => _$ConsentInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsentInput _$ConsentInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConsentInput', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['consent_type', 'version']);
      final val = ConsentInput(
        consentType: $checkedConvert(
          'consent_type',
          (v) => $enumDecode(_$ConsentTypeEnumMap, v),
        ),
        version: $checkedConvert('version', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'consentType': 'consent_type'});

Map<String, dynamic> _$ConsentInputToJson(ConsentInput instance) =>
    <String, dynamic>{
      'consent_type': _$ConsentTypeEnumMap[instance.consentType]!,
      'version': instance.version,
    };

const _$ConsentTypeEnumMap = {
  ConsentType.terms: 'terms',
  ConsentType.privacy: 'privacy',
  ConsentType.healthDataProcessing: 'health_data_processing',
  ConsentType.aiMealProcessing: 'ai_meal_processing',
  ConsentType.progressPhotoStorage: 'progress_photo_storage',
};
