import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

class MobileAppsLinagoraEcosystem extends LinagoraEcosystemProperties {
  final Map<LinagoraEcosystemIdentifier, LinagoraEcosystemProperties?>? apps;

  MobileAppsLinagoraEcosystem(this.apps);

  @override
  List<Object?> get props => [apps];
}