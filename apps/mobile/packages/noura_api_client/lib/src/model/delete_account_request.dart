//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/src/equatable_utils.dart';

part 'delete_account_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeleteAccountRequest {
  /// Returns a new [DeleteAccountRequest] instance.
  DeleteAccountRequest({required this.confirm});

  @JsonKey(name: r'confirm', required: true, includeIfNull: false)
  final DeleteAccountRequestConfirmEnum confirm;

  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DeleteAccountRequest &&
            runtimeType == other.runtimeType &&
            equals([confirm], [other.confirm]);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode([confirm]);

  factory DeleteAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DeleteAccountRequestConfirmEnum {
  @JsonValue(r'DELETE_MY_ACCOUNT')
  DELETE_MY_ACCOUNT(r'DELETE_MY_ACCOUNT');

  const DeleteAccountRequestConfirmEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
