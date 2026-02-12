import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';

abstract class LinagoraEcosystemDatasource {
  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl);
}
