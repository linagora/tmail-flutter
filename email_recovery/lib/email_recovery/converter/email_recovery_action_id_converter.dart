import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

class EmailRecoveryActionIdConverter implements JsonConverter<EmailRecoveryActionId, String> {
  const EmailRecoveryActionIdConverter();

  @override
  EmailRecoveryActionId fromJson(String json) => EmailRecoveryActionId(Id(json));

  @override
  String toJson(EmailRecoveryActionId object) => object.id.value;
}