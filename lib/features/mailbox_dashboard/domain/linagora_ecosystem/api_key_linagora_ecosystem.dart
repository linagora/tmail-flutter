import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/converters/api_key_linagora_ecosystem_converter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

class ApiKeyLinagoraEcosystem extends LinagoraEcosystemProperties {
  final String value;

  ApiKeyLinagoraEcosystem(this.value);

  static LinagoraEcosystemProperties? deserialize(dynamic json) {
    if (json is String) {
      return const ApiKeyLinagoraEcosystemConverter().fromJson(json);
    } else {
      return null;
    }
  }

  @override
  List<Object?> get props => [value];
}