import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_key_linagora_ecosystem.dart';

class ApiKeyLinagoraEcosystemConverter implements JsonConverter<ApiKeyLinagoraEcosystem?, String?> {
  const ApiKeyLinagoraEcosystemConverter();

  @override
  ApiKeyLinagoraEcosystem? fromJson(String? json) => json != null ? ApiKeyLinagoraEcosystem(json) : null;

  @override
  String? toJson(ApiKeyLinagoraEcosystem? object) => object?.value;
}