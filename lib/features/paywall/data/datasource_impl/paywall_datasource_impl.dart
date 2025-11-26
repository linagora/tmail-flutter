import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/paywall/data/datasource/paywall_datasource.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class PaywallDatasourceImpl extends PaywallDatasource {
  final LinagoraEcosystemApi _linagoraEcosystemApi;
  final ExceptionThrower _exceptionThrower;

  PaywallDatasourceImpl(this._linagoraEcosystemApi, this._exceptionThrower);

  @override
  Future<PaywallUrlPattern> getPaywallUrl(String baseUrl) {
    return Future.sync(() async {
      return await _linagoraEcosystemApi.getPaywallUrl(baseUrl);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
}
