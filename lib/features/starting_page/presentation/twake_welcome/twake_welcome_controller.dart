import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tip_dialog/tip_dialog.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_saas_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_in_saas_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class TwakeWelcomeController extends ReloadableController {

  final SignInSaasInteractor _signInSaasInteractor;

  TwakeWelcomeController(this._signInSaasInteractor);

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

    if (AppConfig.saasServerUrl.isEmpty) {
      consumeState(Stream.value(Left(SignInSaasFailure(CanNotFoundSaasServerUrl()))));
      return;
    }

    final baseUri = Uri.tryParse(AppConfig.saasServerUrl);

    if (baseUri == null) {
      consumeState(Stream.value(Left(SignInSaasFailure(SaasServerUriIsNull()))));
      return;
    }

    consumeState(_signInSaasInteractor.execute(
      baseUri: baseUri,
      oidcConfiguration: OIDCConfiguration(
        authority: AppConfig.registrationUrl,
        clientId: OIDCConstant.saasClientId,
        scopes: AppConfig.oidcScopes
      )
    ));
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is SignInSaasSuccess) {
      _handleSignInSaasSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is SignInSaasFailure) {
      _handleSignInSaasFailure(failure);
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

  void _handleSignInSaasSuccess(SignInSaasSuccess success) {
    dynamicUrlInterceptors.setJmapUrl(success.baseUri.toString());
    dynamicUrlInterceptors.changeBaseUrl(success.baseUri.toString());
    authorizationInterceptors.setTokenAndAuthorityOidc(
      newToken: success.tokenOIDC,
      newConfig: success.oidcConfiguration);
    authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
      newToken: success.tokenOIDC,
      newConfig: success.oidcConfiguration);
    getSessionAction();
  }

  void _handleSignInSaasFailure(SignInSaasFailure failure) {
    TipDialogHelper.dismiss();

    toastManager.showMessageFailure(failure);
  }
}