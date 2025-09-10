import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/domain/usecases/get_paywall_url_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

extension ValidateSaasPremiumAvailableExtension on MailboxDashBoardController {
  bool validatePremiumIsAvailable() {
    if (accountId.value == null || sessionCurrent == null) {
      return false;
    }
    return isPremiumAvailable(
      accountId: accountId.value,
      session: sessionCurrent,
    );
  }

  void loadPaywallUrl() {
    final getPaywallUrlInteractor = getBinding<GetPaywallUrlInteractor>();
    final jmapUrl = dynamicUrlInterceptors.jmapUrl;

    if (getPaywallUrlInteractor != null && jmapUrl != null) {
      consumeState(getPaywallUrlInteractor.execute(jmapUrl));
    } else {
      paywallUrlPattern = null;
    }
  }

  void loadPaywallUrlSuccess(PaywallUrlPattern newPattern) {
    paywallUrlPattern = newPattern;
  }

  void navigateToPaywall(BuildContext context) {
    if (paywallUrlPattern == null) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).paywallUrlNotAvailable,
      );
      return;
    }

    final qualifiedPaywall = paywallUrlPattern!.getQualifiedUrl(
      ownerEmail: ownEmailAddress.value,
      domainName: RouteUtils.getRootDomain(),
    );

    AppUtils.launchLink(qualifiedPaywall);
  }
}
