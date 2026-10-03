// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_ref.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExerciseRefCWProxy {
  ExerciseRef id(String id);

  ExerciseRef name(String name);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseRef(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseRef call({String id, String name});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExerciseRef.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExerciseRef.copyWith.fieldName(...)`
class _$ExerciseRefCWProxyImpl implements _$ExerciseRefCWProxy {
  const _$ExerciseRefCWProxyImpl(this._value);

  final ExerciseRef _value;

  @override
  ExerciseRef id(String id) => this(id: id);

  @override
  ExerciseRef name(String name) => this(name: name);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExerciseRef(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExerciseRef(...).copyWith(id: 12, name: "My name")
  /// ````
  ExerciseRef call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
  }) {
    return ExerciseRef(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
    );
  }
}

extension $ExerciseRefCopyWith on ExerciseRef {
  /// Returns a callable class that can be used as follows: `instanceOfExerciseRef.copyWith(...)` or like so:`instanceOfExerciseRef.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExerciseRefCWProxy get copyWith => _$ExerciseRefCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseRef _$ExerciseRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExerciseRef', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name']);
      final val = ExerciseRef(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ExerciseRefToJson(ExerciseRef instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
