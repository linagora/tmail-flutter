import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_controller.dart';

extension ValidatePremiumStorageExtension on MailboxDashBoardController {
  bool validatePremiumIsAvailable() {
    if (accountId.value == null || sessionCurrent == null) {
      return false;
    }
    return isPremiumAvailable(
      accountId: accountId.value,
      session: sessionCurrent,
    );
  }

  bool validateIncreaseSpaceIsAvailable({String? workplaceFqdn}) {
    if (!validatePremiumIsAvailable()) return false;
    return paywallController?.canNavigateToPaywall(
      workplaceFqdn: workplaceFqdn,
      ecosystemPaywallUrlPattern: cachedEcosystemPaywallUrlPattern,
    ) ?? false;
  }

  PaywallUrlPattern? get cachedEcosystemPaywallUrlPattern {
    final paywallUrlTemplate = cachedLinagoraEcosystem?.paywallUrlTemplate;
    if (paywallUrlTemplate == null) return null;

    return PaywallUrlPattern(paywallUrlTemplate);
  }

  bool validateUserHasIsAlreadyHighestSubscription() {
    if (accountId.value == null || sessionCurrent == null) {
      return false;
    }
    return isAlreadyHighestSubscription(
      accountId: accountId.value,
      session: sessionCurrent,
    );
  }
}
