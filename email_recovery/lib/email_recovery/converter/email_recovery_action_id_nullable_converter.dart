import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:json_annotation/json_annotation.dart';

class EmailRecoveryActionIdNullableConverter implements JsonConverter<EmailRecoveryActionId?, String?> {
  const EmailRecoveryActionIdNullableConverter();

  @override
  EmailRecoveryActionId? fromJson(String? json) => json != null ?  EmailRecoveryActionId(Id(json)) : null;

  @override
  String? toJson(EmailRecoveryActionId? object) => object?.id.value;
}