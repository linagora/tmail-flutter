import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
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
      final qualifiedPaywall = paywallUrlPattern!.getQualifiedUrl(
        ownerEmail: ownEmailAddress,
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
      ownerEmail: ownEmailAddress,
      domainName: RouteUtils.getRootDomain(),
    );

    AppUtils.launchLink(qualifiedPaywall);
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
