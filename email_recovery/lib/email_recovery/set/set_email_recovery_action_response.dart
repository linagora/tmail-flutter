import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:jmap_dart_client/http/converter/id_converter.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/set_response.dart';

class SetEmailRecoveryActionResponse extends SetResponseNoAccount<EmailRecoveryAction> {
  SetEmailRecoveryActionResponse({
    Map<Id, EmailRecoveryAction>? created,
    Map<Id, EmailRecoveryAction?>? updated,
    Set<Id>? destroyed,
    Map<Id, SetError>? notCreated,
    Map<Id, SetError>? notUpdated,
    Map<Id, SetError>? notDestroyed
  }) : super(
    created: created,
    updated: updated,
    destroyed: destroyed,
    notCreated: notCreated,
    notUpdated: notUpdated,
    notDestroyed: notDestroyed
  );

  static SetEmailRecoveryActionResponse deserialize(Map<String, dynamic> json) {
    return SetEmailRecoveryActionResponse(
      created: (json['created'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        EmailRecoveryAction.fromJson(value as Map<String, dynamic>)
      )),
      updated: (json['updated'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        value != null ? EmailRecoveryAction.fromJson(value as Map<String, dynamic>) : null
      )),
      destroyed: (json['destroyed'] as List<dynamic>?)?.map((id) => const IdConverter().fromJson(id)).toSet(),
      notCreated: (json['notCreated'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        SetError.fromJson(value)
      )),
      notUpdated: (json['notUpdated'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        SetError.fromJson(value)
      )),
      notDestroyed: (json['notDestroyed'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(
        const IdConverter().fromJson(key),
        SetError.fromJson(value)
      )),
    );
  }

  @override
  List<Object?> get props => [
    created,
    updated,
    destroyed,
    notCreated,
    notUpdated,
    notDestroyed
  ];
}