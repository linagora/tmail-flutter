import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';

abstract class PaywallDatasource {
  Future<PaywallUrlPattern> getPaywallUrl(String baseUrl);
}
