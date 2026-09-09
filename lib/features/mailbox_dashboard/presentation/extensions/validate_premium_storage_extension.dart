import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

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
    if (PaywallUtils.buildWorkplacePaywallUrl(workplaceFqdn).isNotEmpty) {
      return true;
    }
    return PaywallUtils.isValidPaywallUrl(_qualifiedEcosystemPaywallUrl());
  }

  String? _qualifiedEcosystemPaywallUrl() {
    final paywallUrlTemplate = cachedLinagoraEcosystem?.paywallUrlTemplate;
    if (paywallUrlTemplate == null) return null;

    return PaywallUrlPattern(paywallUrlTemplate).getQualifiedUrl(
      ownerEmail: ownEmailAddress.value,
      domainName: RouteUtils.getRootDomain(),
    );
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
