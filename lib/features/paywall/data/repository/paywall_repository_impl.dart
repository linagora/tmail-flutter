import 'package:tmail_ui_user/features/paywall/data/datasource/paywall_datasource.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/domain/repository/paywall_repository.dart';

class PaywallRepositoryImpl extends PaywallRepository {
  final PaywallDatasource _paywallDatasource;

  PaywallRepositoryImpl(this._paywallDatasource);

  @override
  Future<PaywallUrlPattern> getPaywallUrl(String baseUrl) {
    return _paywallDatasource.getPaywallUrl(baseUrl);
  }
}
