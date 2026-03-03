import 'package:core/utils/app_logger.dart';
import 'package:scribe/scribe/ai/data/service/prompt_service.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_system_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SetupScribePromptUrlExtension on MailboxDashBoardController {
  void loadLinagoraEcosystem() {
    if (cachedLinagoraEcosystem != null) {
      _applyScribePromptUrl(cachedLinagoraEcosystem!.scribePromptUrl);
      return;
    }

    final interactor = getBinding<GetLinagoraEcosystemInteractor>();

    if (interactor != null) {
      final baseUrl = dynamicUrlInterceptors.jmapUrl;
      if (baseUrl != null && baseUrl.isNotEmpty) {
        consumeState(interactor.execute(baseUrl));
      } else {
        logError('SetupScribePromptUrlExtension::loadLinagoraEcosystem: jmapUrl is null or empty');
      }
    } else {
      logError('SetupScribePromptUrlExtension::loadLinagoraEcosystem: GetLinagoraEcosystemInteractor not found');
    }
  }

  void handleGetLinagoraEcosystemSuccess(GetLinagoraEcosystemSuccess success) {
    cachedLinagoraEcosystem = success.linagoraEcosystem;
    _applyScribePromptUrl(cachedLinagoraEcosystem!.scribePromptUrl);
  }

  void handleGetLinagoraEcosystemFailure(GetLinagoraEcosystemFailure failure) {
    logError('SetupScribePromptUrlExtension::handleGetLinagoraEcosystemFailure: GetScribePromptUrl failed - ${failure.exception}');
    _applyScribePromptUrl(null);
  }

  void _applyScribePromptUrl(String? promptUrl) {
    final promptService = getBinding<PromptService>();

    if (promptService != null) {
      promptService.setPromptUrl(promptUrl);
    } else {
      logWarning('SetupScribePromptUrlExtension::_applyScribePromptUrl: PromptService not found');
    }
  }
}
