import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/domain/state/get_paywall_url_state.dart';
import 'package:tmail_ui_user/features/paywall/domain/usecases/get_paywall_url_interactor.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class PaywallController extends BaseController {
  final String ownEmailAddress;

  PaywallController({required this.ownEmailAddress});

  void _loadPaywallUrl() {
    final getPaywallUrlInteractor = getBinding<GetPaywallUrlInteractor>();
    final jmapUrl = dynamicUrlInterceptors.jmapUrl;

    if (getPaywallUrlInteractor != null && jmapUrl != null) {
      consumeState(getPaywallUrlInteractor.execute(jmapUrl));
    } else {
      _loadPaywallUrlFailure();
    }
  }

  void _loadPaywallUrlSuccess(PaywallUrlPattern newPattern) {
    _redirectPaywallPage(newPattern);
  }

  void _loadPaywallUrlFailure() {
    _showMessagePaywallUrlNotAvailable();
  }

  void _showMessagePaywallUrlNotAvailable() {
    if (currentOverlayContext == null || currentContext == null) return;

    final appLocalizations = AppLocalizations.of(currentContext!);
    
    appToast.showToastMessage(
      currentOverlayContext!,
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

  void navigateToPaywall({
    String? workplaceFqdn,
    PaywallUrlPattern? ecosystemPaywallUrlPattern,
  }) {
    try {
      final paywallUrl = resolvePaywallUrl(
        workplaceFqdn: workplaceFqdn ??
            twakeAppManager.oidcUserInfo?.workplaceFqdn,
        ecosystemPaywallUrlPattern: ecosystemPaywallUrlPattern,
      );
      if (paywallUrl != null) {
        _openPaywallUrl(paywallUrl);
        return;
      }
    } catch (error, stackTrace) {
      logWarning(
        '$runtimeType::navigateToPaywall: '
        'errorType=${error.runtimeType} | stackTrace=$stackTrace',
      );
    }

    if (ecosystemPaywallUrlPattern != null) {
      _loadPaywallUrlFailure();
      return;
    }
    _loadPaywallUrl();
  }

  void _redirectPaywallPage(PaywallUrlPattern urlPattern) {
    final paywallUrl = resolvePaywallUrl(
      ecosystemPaywallUrlPattern: urlPattern,
    );
    if (paywallUrl == null) {
      _loadPaywallUrlFailure();
      return;
    }
    _openPaywallUrl(paywallUrl);
  }

  void _openPaywallUrl(String paywallUrl) {
    if (PlatformInfo.isWeb &&
        !PaywallUtils.isValidPaywallUrl(paywallUrl)) {
      logWarning('$runtimeType::_openPaywallUrl: Invalid paywall URL');
      _loadPaywallUrlFailure();
      return;
    }
    AppUtils.launchLink(paywallUrl);
  }

  void _handleRetryGetPaywallUrl() {
    _loadPaywallUrl();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetPaywallUrlSuccess) {
      _loadPaywallUrlSuccess(success.paywallUrlPattern);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetPaywallUrlFailure) {
      _loadPaywallUrlFailure();
    } else {
      super.handleFailureViewState(failure);
    }
  }
}

extension PaywallAvailabilityExtension on PaywallController {
  bool canNavigateToPaywall({
    String? workplaceFqdn,
    PaywallUrlPattern? ecosystemPaywallUrlPattern,
  }) {
    try {
      return PaywallUtils.isValidPaywallUrl(resolvePaywallUrl(
        workplaceFqdn: workplaceFqdn,
        ecosystemPaywallUrlPattern: ecosystemPaywallUrlPattern,
      ));
    } catch (error, stackTrace) {
      logWarning(
        '$runtimeType::canNavigateToPaywall: '
        'errorType=${error.runtimeType} | stackTrace=$stackTrace',
      );
      return false;
    }
  }

  String? resolvePaywallUrl({
    String? workplaceFqdn,
    PaywallUrlPattern? ecosystemPaywallUrlPattern,
  }) {
    final workplacePaywallUrl = PaywallUtils.buildWorkplacePaywallUrl(
      workplaceFqdn,
    );
    if (workplacePaywallUrl.isNotEmpty) return workplacePaywallUrl;
    if (ecosystemPaywallUrlPattern == null) return null;

    return ecosystemPaywallUrlPattern.getQualifiedUrl(
      ownerEmail: ownEmailAddress,
      domainName: RouteUtils.getRootDomain(),
    );
  }
}
