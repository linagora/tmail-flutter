import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_linagora_ecosystem_state.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_system_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/drive_attachment_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/linagora_ecosystem_handler_registry.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/scribe_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/linagora_ecosystem/sentry_ecosystem_handler.dart';

extension SetupLinagoraEcoSystemExtension on MailboxDashBoardController {
  void loadLinagoraEcosystem() {
    _registerEcosystemHandlers();

    if (cachedLinagoraEcosystem != null) {
      Get.find<LinagoraEcosystemHandlerRegistry>().dispatchLoaded(cachedLinagoraEcosystem!);
      return;
    }

    final interactor = getBinding<GetLinagoraEcosystemInteractor>();

    if (interactor != null) {
      final baseUrl = dynamicUrlInterceptors.jmapUrl;
      if (baseUrl != null && baseUrl.isNotEmpty) {
        consumeState(interactor.execute(baseUrl));
      } else {
        logWarning('SetupLinagoraEcoSystemExtension::loadLinagoraEcosystem: jmapUrl is null or empty');
      }
    } else {
      logWarning('SetupLinagoraEcoSystemExtension::loadLinagoraEcosystem: GetLinagoraEcosystemInteractor not found');
    }
  }

  void handleGetLinagoraEcosystemSuccess(GetLinagoraEcosystemSuccess success) {
    cachedLinagoraEcosystem = success.linagoraEcosystem;
    Get.find<LinagoraEcosystemHandlerRegistry>().dispatchLoaded(cachedLinagoraEcosystem!);
  }

  void handleGetLinagoraEcosystemFailure(GetLinagoraEcosystemFailure failure) {
    logWarning('SetupLinagoraEcoSystemExtension::handleGetLinagoraEcosystemFailure: ${failure.exception}');
    cachedLinagoraEcosystem = null;
    Get.find<LinagoraEcosystemHandlerRegistry>().dispatchCleared();
  }

  void _registerEcosystemHandlers() {
    final registry = Get.find<LinagoraEcosystemHandlerRegistry>();
    if (registry.hasHandlers) return;
    registry
      ..register(DriveAttachmentEcosystemHandler())
      ..register(ScribeEcosystemHandler())
      ..register(SentryEcosystemHandler(setUpSentry: setUpSentry));
  }
}
