import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_url_linagora_ecosystem.dart';

class ApiUrlLinagoraEcosystemConverter implements JsonConverter<ApiUrlLinagoraEcosystem?, String?> {
  const ApiUrlLinagoraEcosystemConverter();

  @override
  ApiUrlLinagoraEcosystem? fromJson(String? json) => json != null ? ApiUrlLinagoraEcosystem(json) : null;

  @override
  String? toJson(ApiUrlLinagoraEcosystem? object) => object?.value;
}