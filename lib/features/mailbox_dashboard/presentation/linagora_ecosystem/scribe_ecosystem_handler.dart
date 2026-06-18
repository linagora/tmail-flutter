import 'package:core/utils/app_logger.dart';
import 'package:scribe/scribe/ai/data/service/prompt_service.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ScribeEcosystemHandler implements LinagoraEcosystemHandler {
  @override
  void onEcosystemLoaded(LinagoraEcosystem ecosystem) {
    final promptService = getBinding<PromptService>();
    if (promptService != null) {
      promptService.setPromptUrl(ecosystem.scribePromptUrl);
    } else {
      logWarning('ScribeEcosystemHandler::onEcosystemLoaded: PromptService not found');
    }
  }

  @override
  void onEcosystemCleared() {
    getBinding<PromptService>()?.setPromptUrl(null);
  }
}
