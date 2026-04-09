import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
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
      _setUpSentry(cachedLinagoraEcosystem!);
      return;
    }

    final interactor = getBinding<GetLinagoraEcosystemInteractor>();

    if (interactor != null) {
      final baseUrl = dynamicUrlInterceptors.jmapUrl;
      if (baseUrl != null && baseUrl.isNotEmpty) {
        consumeState(interactor.execute(baseUrl));
      } else {
        logWarning('SetupScribePromptUrlExtension::loadLinagoraEcosystem: jmapUrl is null or empty');
      }
    } else {
      logWarning('SetupScribePromptUrlExtension::loadLinagoraEcosystem: GetLinagoraEcosystemInteractor not found');
    }
  }

  void handleGetLinagoraEcosystemSuccess(GetLinagoraEcosystemSuccess success) {
    cachedLinagoraEcosystem = success.linagoraEcosystem;
    _applyScribePromptUrl(cachedLinagoraEcosystem!.scribePromptUrl);
    _setUpSentry(cachedLinagoraEcosystem!);
  }

  void handleGetLinagoraEcosystemFailure(GetLinagoraEcosystemFailure failure) {
    logWarning('SetupScribePromptUrlExtension::handleGetLinagoraEcosystemFailure: GetScribePromptUrl failed - ${failure.exception}');
    cachedLinagoraEcosystem = null;
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

  void _setUpSentry(LinagoraEcosystem ecosystem) {
    if (PlatformInfo.isWeb) return;
    final sentryConfigEcosystem = ecosystem.sentryConfigEcosystem;
    if (sentryConfigEcosystem != null) {
      setUpSentry(sentryConfigEcosystem);
    } else {
      logWarning(
        'LinagoraEcosystemController:_setUpSentry: Sentry config ecosystem is null',
      );
    }
  }
}
