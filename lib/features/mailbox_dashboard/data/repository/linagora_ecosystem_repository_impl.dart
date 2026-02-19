import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';

class LinagoraEcosystemRepositoryImpl extends LinagoraEcosystemRepository {
  final LinagoraEcosystemApi _linagoraEcosystemApi;

  LinagoraEcosystemRepositoryImpl(this._linagoraEcosystemApi);

  @override
  Future<String?> getScribePromptUrl(String baseUrl) {
    return _linagoraEcosystemApi.getScribePromptUrl(baseUrl);
  }
}