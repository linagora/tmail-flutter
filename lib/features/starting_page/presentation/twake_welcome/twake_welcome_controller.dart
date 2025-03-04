import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_up_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_in_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_up_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class TwakeWelcomeController extends ReloadableController {

  final SignInTwakeWorkplaceInteractor _signInTwakeWorkplaceInteractor;
  final SignUpTwakeWorkplaceInteractor _signUpTwakeWorkplaceInteractor;

  DeepLinksManager? _deepLinksManager;
  StreamSubscription<DeepLinkData?>? _deepLinkDataStreamSubscription;

  TwakeWelcomeController(
    this._signInTwakeWorkplaceInteractor,
    this._signUpTwakeWorkplaceInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    if (PlatformInfo.isMobile) {
      _registerDeepLinks();
    }
  }

  void _registerDeepLinks() {
    _deepLinksManager = getBinding<DeepLinksManager>();
    _deepLinksManager?.clearPendingDeepLinkData();
    _deepLinkDataStreamSubscription = _deepLinksManager
        ?.pendingDeepLinkData.stream
        .listen(_handlePendingDeepLinkDataStream);
  }

  void _handlePendingDeepLinkDataStream(DeepLinkData? deepLinkData) {
    log('TwakeWelcomeController::_handlePendingDeepLinkDataStream:DeepLinkData = $deepLinkData');
    _deepLinksManager?.handleDeepLinksWhenAppRunning(
      deepLinkData: deepLinkData,
      onSuccessCallback: (deepLinkData) {
        if (deepLinkData is! OpenAppDeepLinkData) return;

        if (currentContext != null) {
          SmartDialog.showLoading(msg: AppLocalizations.of(currentContext!).loadingPleaseWait);
        }

        _deepLinksManager?.autoSignInViaDeepLink(
          openAppDeepLinkData: deepLinkData,
          onAutoSignInSuccessCallback: _handleAutoSignInViaDeepLinkSuccess,
          onFailureCallback: SmartDialog.dismiss,
        );
      },
    );
  }

  void _handleAutoSignInViaDeepLinkSuccess(AutoSignInViaDeepLinkSuccess success) {
    _synchronizeTokenAndGetSession(
      baseUri: success.baseUri,
      tokenOIDC: success.tokenOIDC,
      oidcConfiguration: success.oidcConfiguration,
    );
  }

  void handleUseCompanyServer() {
    popAndPush(
      AppRoutes.login,
      arguments: LoginArguments(LoginFormType.dnsLookupForm));
  }

  void onClickPrivacyPolicy() {
    AppUtils.launchLink(AppConfig.linagoraPrivacyUrl);
  }

  void onClickSignIn(BuildContext context) {
    SmartDialog.showLoading(msg: AppLocalizations.of(context).loadingPleaseWait);

    final baseUri = Uri.tryParse(AppConfig.saasJmapServerUrl);

    if (baseUri == null) {
      consumeState(Stream.value(Left(SignInTwakeWorkplaceFailure(SaasServerUriIsNull()))));
      return;
    }

    consumeState(_signInTwakeWorkplaceInteractor.execute(
      baseUri: baseUri,
      oidcConfiguration: OIDCConfiguration(
        authority: AppConfig.saasRegistrationUrl,
        clientId: OIDCConstant.clientId,
        scopes: AppConfig.oidcScopes,
        isTWP: true,
      )
    ));
  }

  void onSignUpTwakeWorkplace(BuildContext context) {
    SmartDialog.showLoading(msg: AppLocalizations.of(context).loadingPleaseWait);

    final baseUri = Uri.tryParse(AppConfig.saasJmapServerUrl);

    if (baseUri == null) {
      consumeState(Stream.value(Left(SignUpTwakeWorkplaceFailure(SaasServerUriIsNull()))));
      return;
    }

    consumeState(_signUpTwakeWorkplaceInteractor.execute(
      baseUri: baseUri,
      oidcConfiguration: OIDCConfiguration(
        authority: AppConfig.saasRegistrationUrl,
        clientId: OIDCConstant.clientId,
        scopes: AppConfig.oidcScopes,
        isTWP: true,
      )
    ));
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is SignInTwakeWorkplaceSuccess) {
      _synchronizeTokenAndGetSession(
        baseUri: success.baseUri,
        tokenOIDC: success.tokenOIDC,
        oidcConfiguration: success.oidcConfiguration,
      );
    } else if (success is SignUpTwakeWorkplaceSuccess) {
      _synchronizeTokenAndGetSession(
        baseUri: success.baseUri,
        tokenOIDC: success.tokenOIDC,
        oidcConfiguration: success.oidcConfiguration,
      );
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is SignInTwakeWorkplaceFailure || failure is SignUpTwakeWorkplaceFailure) {
      SmartDialog.dismiss();
      toastManager.show(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleReloaded(Session session) {
    SmartDialog.dismiss();

    popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: session);
  }

  @override
  void handleGetSessionFailure(GetSessionFailure failure) {
    SmartDialog.dismiss();
    toastManager.show(failure);
  }

  @override
  void handleUrgentExceptionOnMobile({Failure? failure, Exception? exception}) {
    SmartDialog.dismiss();
    super.handleUrgentExceptionOnMobile(failure: failure, exception: exception);
  }

  void _synchronizeTokenAndGetSession({
    required Uri baseUri,
    required TokenOIDC tokenOIDC,
    required OIDCConfiguration oidcConfiguration,
  }) {
    setDataToInterceptors(
      baseUrl: baseUri.toString(),
      tokenOIDC: tokenOIDC,
      oidcConfiguration: oidcConfiguration,
    );

    getSessionAction();
  }

  @override
  void onClose() {
    if (PlatformInfo.isMobile) {
      _deepLinkDataStreamSubscription?.cancel();
    }
    super.onClose();
  }
}