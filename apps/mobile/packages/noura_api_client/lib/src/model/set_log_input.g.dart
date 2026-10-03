// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_log_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetLogInputCWProxy {
  SetLogInput exerciseId(String exerciseId);

  SetLogInput setOrdinal(int setOrdinal);

  SetLogInput reps(int? reps);

  SetLogInput loadKg(num? loadKg);

  SetLogInput skipped(bool skipped);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetLogInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetLogInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SetLogInput call({
    String exerciseId,
    int setOrdinal,
    int? reps,
    num? loadKg,
    bool skipped,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSetLogInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSetLogInput.copyWith.fieldName(...)`
class _$SetLogInputCWProxyImpl implements _$SetLogInputCWProxy {
  const _$SetLogInputCWProxyImpl(this._value);

  final SetLogInput _value;

  @override
  SetLogInput exerciseId(String exerciseId) => this(exerciseId: exerciseId);

  @override
  SetLogInput setOrdinal(int setOrdinal) => this(setOrdinal: setOrdinal);

  @override
  SetLogInput reps(int? reps) => this(reps: reps);

  @override
  SetLogInput loadKg(num? loadKg) => this(loadKg: loadKg);

  @override
  SetLogInput skipped(bool skipped) => this(skipped: skipped);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SetLogInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SetLogInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SetLogInput call({
    Object? exerciseId = const $CopyWithPlaceholder(),
    Object? setOrdinal = const $CopyWithPlaceholder(),
    Object? reps = const $CopyWithPlaceholder(),
    Object? loadKg = const $CopyWithPlaceholder(),
    Object? skipped = const $CopyWithPlaceholder(),
  }) {
    return SetLogInput(
      exerciseId: exerciseId == const $CopyWithPlaceholder()
          ? _value.exerciseId
          // ignore: cast_nullable_to_non_nullable
          : exerciseId as String,
      setOrdinal: setOrdinal == const $CopyWithPlaceholder()
          ? _value.setOrdinal
          // ignore: cast_nullable_to_non_nullable
          : setOrdinal as int,
      reps: reps == const $CopyWithPlaceholder()
          ? _value.reps
          // ignore: cast_nullable_to_non_nullable
          : reps as int?,
      loadKg: loadKg == const $CopyWithPlaceholder()
          ? _value.loadKg
          // ignore: cast_nullable_to_non_nullable
          : loadKg as num?,
      skipped: skipped == const $CopyWithPlaceholder()
          ? _value.skipped
          // ignore: cast_nullable_to_non_nullable
          : skipped as bool,
    );
  }
}

extension $SetLogInputCopyWith on SetLogInput {
  /// Returns a callable class that can be used as follows: `instanceOfSetLogInput.copyWith(...)` or like so:`instanceOfSetLogInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetLogInputCWProxy get copyWith => _$SetLogInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetLogInput _$SetLogInputFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SetLogInput',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'exercise_id',
        'set_ordinal',
        'reps',
        'load_kg',
        'skipped',
      ],
    );
    final val = SetLogInput(
      exerciseId: $checkedConvert('exercise_id', (v) => v as String),
      setOrdinal: $checkedConvert('set_ordinal', (v) => (v as num).toInt()),
      reps: $checkedConvert('reps', (v) => (v as num?)?.toInt()),
      loadKg: $checkedConvert('load_kg', (v) => v as num?),
      skipped: $checkedConvert('skipped', (v) => v as bool),
    );
    return val;
  },
  fieldKeyMap: const {
    'exerciseId': 'exercise_id',
    'setOrdinal': 'set_ordinal',
    'loadKg': 'load_kg',
  },
);

Map<String, dynamic> _$SetLogInputToJson(SetLogInput instance) =>
    <String, dynamic>{
      'exercise_id': instance.exerciseId,
      'set_ordinal': instance.setOrdinal,
      'reps': instance.reps,
      'load_kg': instance.loadKg,
      'skipped': instance.skipped,
    };
