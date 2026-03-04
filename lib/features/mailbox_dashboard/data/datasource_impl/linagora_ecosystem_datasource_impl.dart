import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/linagora_ecosystem_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LinagoraEcosystemDatasourceImpl extends LinagoraEcosystemDatasource {
  final LinagoraEcosystemApi _linagoraEcosystemApi;
  final ExceptionThrower _exceptionThrower;

  LinagoraEcosystemDatasourceImpl(
    this._linagoraEcosystemApi,
    this._exceptionThrower,
  );

  @override
  Future<LinagoraEcosystem> getLinagoraEcosystem(String baseUrl) {
    return Future.sync(() async {
      return await _linagoraEcosystemApi.getLinagoraEcosystem(baseUrl);
    }).catchError(_exceptionThrower.throwException);
  }
}
