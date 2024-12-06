import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/converters/linagora_ecosystem_converter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/mobile_apps_linagora_ecosystem.dart';

class MobileAppsLinagoraEcosystemConverter extends LinagoraEcosystemConverter {
  static final defaultConverter = MobileAppsLinagoraEcosystemConverter();

  static MobileAppsLinagoraEcosystem? deserialize(dynamic json) {
    if (json is Map<String, dynamic>) {
      final apps = json.map((key, value) => defaultConverter.convert(key, value));
      return MobileAppsLinagoraEcosystem(apps);
    } else {
      return null;
    }
  }
}