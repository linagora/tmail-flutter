import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_controller.dart';

class RecordingPaywallController extends PaywallController {
  int navigateCount = 0;
  String? navigatedWorkplaceFqdn;
  PaywallUrlPattern? navigatedEcosystemPattern;

  RecordingPaywallController() : super(ownEmailAddress: 'alice@domain.tld');

  @override
  void navigateToPaywall({
    String? workplaceFqdn,
    PaywallUrlPattern? ecosystemPaywallUrlPattern,
  }) {
    navigateCount++;
    navigatedWorkplaceFqdn = workplaceFqdn;
    navigatedEcosystemPattern = ecosystemPaywallUrlPattern;
  }
}
