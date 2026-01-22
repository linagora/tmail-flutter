import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/linagora_ecosystem_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';

class LinagoraEcosystemRepositoryImpl extends LinagoraEcosystemRepository {
  final LinagoraEcosystemDatasource _ecosystemDatasource;

  LinagoraEcosystemRepositoryImpl(this._ecosystemDatasource);

  @override
  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) {
    return _ecosystemDatasource.getLinagoraEcosystem(baseUrl);
  }
}
