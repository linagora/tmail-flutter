import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_app_dashboard_configuration_interactor.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class AppGridDashboardController {
  final isAppGridDashboardOverlayOpen = false.obs;
  final appDashboardExpandMode = ExpandMode.COLLAPSE.obs;
  final linagoraApplications = Rxn<LinagoraApplications>();

  final GetAppDashboardConfigurationInteractor _getAppDashboardConfigurationInteractor;

  AppGridDashboardController(this._getAppDashboardConfigurationInteractor);

  void toggleAppGridDashboard() {
    isAppGridDashboardOverlayOpen.toggle();
    final newExpandMode = appDashboardExpandMode.value == ExpandMode.EXPAND
        ? ExpandMode.COLLAPSE
        : ExpandMode.EXPAND;
    appDashboardExpandMode.value = newExpandMode;
  }

  Stream<Either<Failure, Success>> showDashboardAction() {
    return _getAppDashboardConfigurationInteractor.execute(AppConfig.appDashboardConfigurationPath);
  }

  void handleShowAppDashboard(LinagoraApplications linagoraApps) {
    log('AppGridDashboardController::handleShowAppDashboard(): $linagoraApps');
    isAppGridDashboardOverlayOpen.value = true;
    appDashboardExpandMode.value = ExpandMode.EXPAND;
    linagoraApplications.value = linagoraApps;
  }
}