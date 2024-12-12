import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_app_dashboard_configuration_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_app_grid_linagora_ecosystem_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_app_dashboard_configuration_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_app_grid_linagra_ecosystem_interactor.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class AppGridDashboardController extends BaseController {
  final listLinagoraApp = RxList<AppLinagoraEcosystem>();

  final GetAppDashboardConfigurationInteractor _getAppDashboardConfigurationInteractor;
  final GetAppGridLinagraEcosystemInteractor _getAppGridLinagraEcosystemInteractor;

  AppGridDashboardController(
    this._getAppDashboardConfigurationInteractor,
    this._getAppGridLinagraEcosystemInteractor,
  );

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAppDashboardConfigurationSuccess) {
      syncLinagoraApps(success.listLinagoraApp);
    } else if (success is GetAppGridLinagraEcosystemSuccess) {
      syncLinagoraApps(success.listAppLinagoraEcosystem);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  void loadAppDashboardConfiguration() {
    consumeState(_getAppDashboardConfigurationInteractor.execute(
      AppConfig.appDashboardConfigurationPath,
    ));
  }

  void loadAppGridLinagraEcosystem(String baseUrl) {
    consumeState(_getAppGridLinagraEcosystemInteractor.execute(baseUrl));
  }

  void syncLinagoraApps(List<AppLinagoraEcosystem> linagoraApps) {
    log('AppGridDashboardController::setListLinagoraApp:linagoraApps = $linagoraApps');
    listLinagoraApp.value = linagoraApps;
  }
}