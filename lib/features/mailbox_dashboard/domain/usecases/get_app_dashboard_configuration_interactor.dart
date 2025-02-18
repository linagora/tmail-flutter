import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/app_grid_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_app_dashboard_configuration_state.dart';

class GetAppDashboardConfigurationInteractor {
  final AppGridRepository _appGridRepository;

  GetAppDashboardConfigurationInteractor(this._appGridRepository);

  Stream<Either<Failure, Success>> execute(String path) async* {
    try {
      yield Right(LoadingAppDashboardConfiguration());
      final linagoraApps = await _appGridRepository.getLinagoraApplicationsFromEnvironment(path);
      yield Right(GetAppDashboardConfigurationSuccess(linagoraApps.apps));
    } catch (e) {
      logError('GetAppDashboardConfigurationInteractor::execute(): $e');
      yield Left(GetAppDashboardConfigurationFailure(e));
    }
  }
}