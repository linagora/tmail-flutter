import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/config/app_config_loader.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/app_dashboard_configuration_parser.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_app_dashboard_configuration_state.dart';

class GetAppDashboardConfigurationInteractor {
  final AppConfigLoader _appConfigLoader;

  GetAppDashboardConfigurationInteractor(this._appConfigLoader);

  Stream<Either<Failure, Success>> execute(String appDashboardConfigurationPath) async* {
    try {
      yield Right(LoadingAppDashboardConfiguration());

      final linagoraApps = await _appConfigLoader.load<LinagoraApplications>(
        appDashboardConfigurationPath,
        AppDashboardConfigurationParser()
      );

      yield Right(GetAppDashboardConfigurationSuccess(linagoraApps));
    } catch (e) {
      logError('GetAppDashboardConfigurationInteractor::execute(): $e');
      yield Left(GetAppDashboardConfigurationFailure(e));
    }
  }
}