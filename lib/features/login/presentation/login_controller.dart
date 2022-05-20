import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/state/login_state.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class LoginController extends GetxController {

  final AuthenticationInteractor _authenticationInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final AuthorizationInterceptors _authorizationInterceptors;
  final CheckOIDCIsAvailableInteractor _checkOIDCIsAvailableInteractor;

  final TextEditingController urlInputController = TextEditingController();

  LoginController(
    this._authenticationInteractor,
    this._dynamicUrlInterceptors,
    this._authorizationInterceptors,
    this._checkOIDCIsAvailableInteractor,
  );

  var loginState = LoginState(Right(LoginInitAction())).obs;
  final loginFormType = LoginFormType.baseUrlForm.obs;

  String? _urlText;
  String? _userNameText;
  String? _passwordText;

  void setUrlText(String url) => _urlText = url.trim().formatURLValid();

  void setUserNameText(String userName) => _userNameText = userName;

  void setPasswordText(String password) => _passwordText = password;

  Uri? _parseUri(String? url) => url != null && url.trim().isNotEmpty
      ? Uri.parse(url.trim())
      : null;

  UserName? _parseUserName(String? userName) => userName != null && userName.trim().isNotEmpty
      ? UserName(userName.trim())
      : null;

  Password? _parsePassword(String? password) => password != null && password.trim().isNotEmpty
      ? Password(password.trim())
      : null;

  void handleNextInUrlInputFormPress() {
    _checkOIDCIsAvailable();
  }

  void _checkOIDCIsAvailable() async {
    final baseUri = BuildUtils.isWeb ? _parseUri(AppConfig.baseUrl) : _parseUri(_urlText);

    if (baseUri == null) {
      loginState.value = LoginState(Left(LoginMissUrlAction()));
    } else {
      loginState.value = LoginState(Right(LoginLoadingAction()));
      await _checkOIDCIsAvailableInteractor
          .execute(OIDCRequest(baseUrl: baseUri.path))
          .then((response) => response.fold(
              (failure) => _showFormLoginWithCredentialAction(),
              (success) => success is CheckOIDCIsAvailableSuccess
                  ? _showFormLoginWithSSOAction(success)
                  : _showFormLoginWithCredentialAction()));
    }
  }

  void _showFormLoginWithSSOAction(CheckOIDCIsAvailableSuccess success) {
    loginState.value = LoginState(Right(success));
    loginFormType.value = LoginFormType.ssoForm;
  }

  void handleBackInCredentialForm() {
    loginState.value = LoginState(Right(LoginInitAction()));
    loginFormType.value = LoginFormType.baseUrlForm;
  }

  void _showFormLoginWithCredentialAction() {
    loginState.value = LoginState(Right(InputUrlCompletion()));
    loginFormType.value = LoginFormType.credentialForm;
  }

  void handleLoginPressed() {
    if (loginFormType.value == LoginFormType.ssoForm) {

    } else {
      final baseUri = kIsWeb ? _parseUri(AppConfig.baseUrl) : _parseUri(_urlText);
      final userName = _parseUserName(_userNameText);
      final password = _parsePassword(_passwordText);
      if (baseUri != null && userName != null && password != null) {
        _loginAction(baseUri, userName, password);
      } else if (baseUri == null) {
        loginState.value = LoginState(Left(LoginMissUrlAction()));
      } else if (userName == null) {
        loginState.value = LoginState(Left(LoginMissUsernameAction()));
      } else if (password == null) {
        loginState.value = LoginState(Left(LoginMissPasswordAction()));
      }
    }
  }

  void _loginAction(Uri baseUrl, UserName userName, Password password) async {
    loginState.value = LoginState(Right(LoginLoadingAction()));
    await _authenticationInteractor.execute(baseUrl, userName, password)
      .then((response) => response.fold(
        (failure) => failure is AuthenticationUserFailure ? _loginFailureAction(failure) : null,
        (success) => success is AuthenticationUserViewState ? _loginSuccessAction(success) : null));
  }

  void _loginSuccessAction(AuthenticationUserViewState success) {
    loginState.value = LoginState(Right(success));
    _dynamicUrlInterceptors.changeBaseUrl(kIsWeb ? AppConfig.baseUrl : _urlText);
    _authorizationInterceptors.changeAuthorization(_userNameText, _passwordText);
    pushAndPop(AppRoutes.SESSION);
  }

  void _loginFailureAction(AuthenticationUserFailure failure) {
    loginState.value = LoginState(Left(failure));
  }

  void formatUrl(String url) {
    if (url.isValid()) {
      urlInputController.text = url.removePrefix();
    }
    setUrlText(urlInputController.text);
  }

  @override
  void onClose() {
    urlInputController.clear();
    super.onClose();
  }
}