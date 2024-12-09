
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/app_grid_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class AppGridDatasourceImpl extends AppGridDatasource {

  final LinagoraEcosystemApi _linagoraEcosystemApi;
  final ExceptionThrower _exceptionThrower;

  AppGridDatasourceImpl(this._linagoraEcosystemApi, this._exceptionThrower);

  @override
  Future<LinagoraApplications> getLinagoraApplications(String path) {
    throw UnimplementedError();
  }

  @override
  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) {
    return Future.sync(() async {
      return await _linagoraEcosystemApi.getLinagoraEcosystem(baseUrl);
    }).catchError(_exceptionThrower.throwException);
  }
}