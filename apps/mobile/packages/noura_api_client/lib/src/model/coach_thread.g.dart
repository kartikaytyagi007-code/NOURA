// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_thread.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachThreadCWProxy {
  CoachThread id(String id);

  CoachThread createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachThread(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachThread(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachThread call({String id, DateTime createdAt});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachThread.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachThread.copyWith.fieldName(...)`
class _$CoachThreadCWProxyImpl implements _$CoachThreadCWProxy {
  const _$CoachThreadCWProxyImpl(this._value);

  final CoachThread _value;

  @override
  CoachThread id(String id) => this(id: id);

  @override
  CoachThread createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachThread(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachThread(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachThread call({
    Object? id = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return CoachThread(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $CoachThreadCopyWith on CoachThread {
  /// Returns a callable class that can be used as follows: `instanceOfCoachThread.copyWith(...)` or like so:`instanceOfCoachThread.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachThreadCWProxy get copyWith => _$CoachThreadCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachThread _$CoachThreadFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CoachThread', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'created_at']);
      final val = CoachThread(
        id: $checkedConvert('id', (v) => v as String),
        createdAt: $checkedConvert(
          'created_at',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'createdAt': 'created_at'});

Map<String, dynamic> _$CoachThreadToJson(CoachThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
    };
