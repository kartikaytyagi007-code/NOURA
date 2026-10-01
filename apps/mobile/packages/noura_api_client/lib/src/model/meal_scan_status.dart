//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum MealScanStatus {
  @JsonValue(r'awaiting_upload')
  awaitingUpload(r'awaiting_upload'),
  @JsonValue(r'queued')
  queued(r'queued'),
  @JsonValue(r'recognizing')
  recognizing(r'recognizing'),
  @JsonValue(r'needs_confirmation')
  needsConfirmation(r'needs_confirmation'),
  @JsonValue(r'ready')
  ready(r'ready'),
  @JsonValue(r'failed')
  failed(r'failed'),
  @JsonValue(r'cancelled')
  cancelled(r'cancelled'),
  @JsonValue(r'expired')
  expired(r'expired');

  const MealScanStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
