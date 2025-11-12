import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/web_link_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/domain/state/get_paywall_url_state.dart';
import 'package:tmail_ui_user/features/paywall/domain/usecases/get_paywall_url_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class PaywallController extends BaseController {
  final String ownEmailAddress;

  PaywallUrlPattern? paywallUrlPattern;
  bool isRetryGetPaywallUrl = false;

  PaywallController({required this.ownEmailAddress});

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
      final qualifiedPaywall = getPaywallUrl(paywallUrlPattern!);
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
    final qualifiedPaywall = getPaywallUrl(paywallUrlPattern!);
    AppUtils.launchLink(qualifiedPaywall);
  }

  String getPaywallUrl(PaywallUrlPattern pattern) {
    final defaultUrl = pattern.getQualifiedUrl(
      ownerEmail: ownEmailAddress,
      domainName: RouteUtils.getRootDomain(),
    );

    try {
      final workplaceFqdn = twakeAppManager.oidcUserInfo?.workplaceFqdn?.trim();
      if (workplaceFqdn == null || workplaceFqdn.isEmpty) {
        return defaultUrl;
      }

      final paywallUrl = WebLinkGenerator.safeGenerateWebLink(
        workplaceFqdn: workplaceFqdn,
        pathname: 'paywall',
      );

      // Fallback if generated URL is empty or invalid
      return paywallUrl.isNotEmpty ? paywallUrl : defaultUrl;
    } catch (e) {
      logError('$runtimeType::getPaywallUrl: Failed to generate paywall URL: $e');
      return defaultUrl;
    }
  }

  void _handleRetryGetPaywallUrl() {
    isRetryGetPaywallUrl = true;
    loadPaywallUrl();
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetPaywallUrlSuccess) {
      loadPaywallUrlSuccess(success.paywallUrlPattern);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetPaywallUrlFailure) {
      loadPaywallUrlFailure();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleErrorViewState(Object error, StackTrace stackTrace) {
    super.handleErrorViewState(error, stackTrace);
    isRetryGetPaywallUrl = false;
  }

  @override
  void handleUrgentExceptionOnWeb({Failure? failure, Exception? exception}) {
    super.handleUrgentExceptionOnWeb(failure: failure, exception: exception);
    isRetryGetPaywallUrl = false;
  }

  @override
  void onClose() {
    paywallUrlPattern = null;
    isRetryGetPaywallUrl = false;
    super.onClose();
  }
}
