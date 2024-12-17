
import 'package:core/utils/config/app_config_loader.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/app_grid_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/app_dashboard_configuration_parser.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LocalAppGridDatasourceImpl extends AppGridDatasource {

  final AppConfigLoader _appConfigLoader;
  final ExceptionThrower _exceptionThrower;

  LocalAppGridDatasourceImpl(this._appConfigLoader, this._exceptionThrower);

  @override
  Future<LinagoraApplications> getLinagoraApplications(String path) {
    return Future.sync(() async {
      return await _appConfigLoader.load<LinagoraApplications>(
        path,
        AppDashboardConfigurationParser(),
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) {
    throw UnimplementedError();
  }
}