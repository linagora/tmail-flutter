import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tip_dialog/tip_dialog.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_up_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_in_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_up_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class TwakeWelcomeController extends ReloadableController {

  final SignInTwakeWorkplaceInteractor _signInTwakeWorkplaceInteractor;
  final SignUpTwakeWorkplaceInteractor _signUpTwakeWorkplaceInteractor;

  TwakeWelcomeController(
    this._signInTwakeWorkplaceInteractor,
    this._signUpTwakeWorkplaceInteractor,
  );

  void handleUseCompanyServer() {
    popAndPush(
      AppRoutes.login,
      arguments: LoginArguments(LoginFormType.dnsLookupForm));
  }

  void onClickPrivacyPolicy() {
    AppUtils.launchLink(AppConfig.linagoraPrivacyUrl);
  }

  void onClickSignIn(BuildContext context) {
    TipDialogHelper.loading(AppLocalizations.of(context).loadingPleaseWait);

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
        scopes: AppConfig.oidcScopes
      )
    ));
  }

  void onSignUpTwakeWorkplace(BuildContext context) {
    TipDialogHelper.loading(AppLocalizations.of(context).loadingPleaseWait);

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
        scopes: AppConfig.oidcScopes
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
    if (failure is SignInTwakeWorkplaceFailure) {
      _handleSignInTwakeWorkplaceFailure(failure);
    } else if (failure is SignUpTwakeWorkplaceFailure) {
      _handleSignUpTwakeWorkplaceFailure(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleReloaded(Session session) {
    TipDialogHelper.dismiss();

    popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: session);
  }

  @override
  void handleGetSessionFailure(GetSessionFailure failure) {
    TipDialogHelper.dismiss();

    toastManager.showMessageFailure(failure);
  }

  void _synchronizeTokenAndGetSession({
    required Uri baseUri,
    required TokenOIDC tokenOIDC,
    required OIDCConfiguration oidcConfiguration,
  }) {
    dynamicUrlInterceptors.setJmapUrl(baseUri.toString());
    dynamicUrlInterceptors.changeBaseUrl(baseUri.toString());
    authorizationInterceptors.setTokenAndAuthorityOidc(
      newToken: tokenOIDC,
      newConfig: oidcConfiguration);
    authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
      newToken: tokenOIDC,
      newConfig: oidcConfiguration);

    getSessionAction();
  }

  void _handleSignInTwakeWorkplaceFailure(SignInTwakeWorkplaceFailure failure) {
    TipDialogHelper.dismiss();

    toastManager.showMessageFailure(failure);
  }

  void _handleSignUpTwakeWorkplaceFailure(SignUpTwakeWorkplaceFailure failure) {
    TipDialogHelper.dismiss();

    toastManager.showMessageFailure(failure);
  }
}