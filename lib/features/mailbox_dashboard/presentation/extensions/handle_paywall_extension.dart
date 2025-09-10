import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/domain/usecases/get_paywall_url_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

extension HandlePaywallExtension on MailboxDashBoardController {
  bool validatePremiumIsAvailable() {
    if (accountId.value == null || sessionCurrent == null) {
      return false;
    }
    return isPremiumAvailable(
      accountId: accountId.value,
      session: sessionCurrent,
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

  void loadPaywallUrl() {
    final getPaywallUrlInteractor = getBinding<GetPaywallUrlInteractor>();
    final jmapUrl = dynamicUrlInterceptors.jmapUrl;

    if (getPaywallUrlInteractor != null && jmapUrl != null) {
      consumeState(getPaywallUrlInteractor.execute(jmapUrl));
    } else {
      paywallUrlPattern = null;
      if (isRetryGetPaywallUrl) {
        _showMessagePaywallUrlNotAvailable();
        isRetryGetPaywallUrl = false;
      }
    }
  }

  void loadPaywallUrlSuccess(PaywallUrlPattern newPattern) {
    paywallUrlPattern = newPattern;
    if (isRetryGetPaywallUrl) {
      isRetryGetPaywallUrl = false;
      final qualifiedPaywall = paywallUrlPattern!.getQualifiedUrl(
        ownerEmail: ownEmailAddress.value,
        domainName: RouteUtils.getRootDomain(),
      );
      AppUtils.launchLink(qualifiedPaywall);
    }
  }

  void loadPaywallUrlFailure() {
    paywallUrlPattern = null;
    if (isRetryGetPaywallUrl) {
      _showMessagePaywallUrlNotAvailable();
      isRetryGetPaywallUrl = false;
    }
  }

  void _showMessagePaywallUrlNotAvailable({BuildContext? context}) {
    final overlayContext = context ?? currentOverlayContext;
    AppLocalizations? appLocalizations;
    if (context != null) {
      appLocalizations = AppLocalizations.of(context);
    } else if (currentContext != null) {
      appLocalizations = AppLocalizations.of(currentContext!);
    }

    if (overlayContext == null || appLocalizations == null) return;

    appToast.showToastMessage(
      overlayContext,
      appLocalizations.paywallUrlNotAvailable,
      actionName: appLocalizations.retry,
      onActionClick: _handleRetryGetPaywallUrl,
      leadingSVGIcon: imagePaths.icQuotasWarning,
      leadingSVGIconColor: Colors.white,
      backgroundColor: AppColor.toastErrorBackgroundColor,
      textColor: Colors.white,
      actionIcon: SvgPicture.asset(
        imagePaths.icRefreshQuotas,
        colorFilter: Colors.white.asFilter(),
      ),
      duration: const Duration(seconds: 5),
    );
  }

  void navigateToPaywall(BuildContext context) {
    if (paywallUrlPattern == null) {
      _showMessagePaywallUrlNotAvailable(context: context);
      return;
    }

    final qualifiedPaywall = paywallUrlPattern!.getQualifiedUrl(
      ownerEmail: ownEmailAddress.value,
      domainName: RouteUtils.getRootDomain(),
    );

    AppUtils.launchLink(qualifiedPaywall);
  }

  void _handleRetryGetPaywallUrl() {
    isRetryGetPaywallUrl = true;
    loadPaywallUrl();
  }
}
