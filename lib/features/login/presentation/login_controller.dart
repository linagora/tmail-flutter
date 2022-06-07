import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
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
  final GetOIDCConfigurationInteractor _getOIDCConfigurationInteractor;
  final GetTokenOIDCInteractor _getTokenOIDCInteractor;
  final AuthenticateOidcOnBrowserInteractor _authenticateOidcOnBrowserInteractor;
  final GetAuthenticationInfoInteractor _getAuthenticationInfoInteractor;
  final GetStoredOidcConfigurationInteractor _getStoredOidcConfigurationInteractor;

  final TextEditingController urlInputController = TextEditingController();

  LoginController(
    this._authenticationInteractor,
    this._dynamicUrlInterceptors,
    this._authorizationInterceptors,
    this._checkOIDCIsAvailableInteractor,
    this._getOIDCConfigurationInteractor,
    this._getTokenOIDCInteractor,
    this._authenticateOidcOnBrowserInteractor,
    this._getAuthenticationInfoInteractor,
    this._getStoredOidcConfigurationInteractor,
  );

  var loginState = LoginState(Right(LoginInitAction())).obs;
  final loginFormType = LoginFormType.baseUrlForm.obs;

  String? _urlText;
  String? _userNameText;
  String? _passwordText;
  OIDCResponse? _oidcResponse;

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

  @override
  void onInit() {
    if (BuildUtils.isWeb) {
      _getAuthenticationInfo();
    }
    super.onInit();
  }

  void _getAuthenticationInfo() async {
    await _getAuthenticationInfoInteractor.execute()
      .then((result) => result.fold(
        (failure) => null,
        (success) {
          if (success is GetAuthenticationInfoSuccess) {
            _getStoredOidcConfiguration();
          }
        }));
  }

  void _getStoredOidcConfiguration() async {
    await _getStoredOidcConfigurationInteractor.execute()
        .then((result) => result.fold(
            (failure) => null,
            (success) {
              if (success is GetStoredOidcConfigurationSuccess) {
                _getTokenOIDCAction(success.oidcConfiguration);
              }
            }));
  }

  void handleNextInUrlInputFormPress() {
    _checkOIDCIsAvailable();
  }

  void _checkOIDCIsAvailable() async {
    final baseUri = BuildUtils.isWeb ? _parseUri(AppConfig.baseUrl) : _parseUri(_urlText);
    log('LoginController::_checkOIDCIsAvailable(): baseUri: $baseUri');
    if (baseUri == null) {
      loginState.value = LoginState(Left(LoginMissUrlAction()));
    } else {
      loginState.value = LoginState(Right(LoginLoadingAction()));
      log('LoginController::_checkOIDCIsAvailable(): origin: + ${baseUri.origin}');
      await _checkOIDCIsAvailableInteractor
          .execute(OIDCRequest(baseUrl: baseUri.toString(), resourceUrl: baseUri.origin))
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
    _oidcResponse = success.oidcResponse;
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
    log('LoginController::handleLoginPressed(): ${loginFormType.value}');
    if (loginFormType.value == LoginFormType.ssoForm) {
      _getOIDCConfiguration();
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

  void handleSSOPressed() async {
    final baseUri = _parseUri(AppConfig.baseUrl);

    if (baseUri != null) {
      log('LoginController::handleSSOPressed(): baseUri: ${baseUri.toString()}');
      loginState.value = LoginState(Right(LoginLoadingAction()));
      await _checkOIDCIsAvailableInteractor
        .execute(OIDCRequest(baseUrl: baseUri.toString(), resourceUrl: baseUri.origin))
        .then((response) => response.fold(
          (failure) => loginState.value = LoginState(Left(LoginSSONotAvailableAction())),
          (success) {
            if (success is CheckOIDCIsAvailableSuccess) {
              loginState.value = LoginState(Right(success));
              _oidcResponse = success.oidcResponse;
              _getOIDCConfiguration();
            } else {
              loginState.value = LoginState(Left(LoginSSONotAvailableAction()));
            }
          }));
    }
  }

  void _getOIDCConfiguration() async {
    loginState.value = LoginState(Right(LoginLoadingAction()));
    if (_oidcResponse != null) {
      await _getOIDCConfigurationInteractor.execute(_oidcResponse!)
        .then((response) => response.fold(
          (failure) {
            if (failure is GetOIDCConfigurationFailure) {
              loginState.value = LoginState(Left(failure));
            } else {
              loginState.value = LoginState(
                  Left(LoginCanNotVerifySSOConfigurationAction()));
            }
          },
          (success) {
            if (success is GetOIDCConfigurationSuccess) {
              _getOIDCConfigurationSuccess(success);
            } else {
              loginState.value = LoginState(
                  Left(LoginCanNotVerifySSOConfigurationAction()));
            }
          }));
    }
  }

  void _getOIDCConfigurationSuccess(GetOIDCConfigurationSuccess success) {
    loginState.value = LoginState(Right(success));
    if (BuildUtils.isWeb) {
      _authenticateOidcOnBrowserAction(success.oidcConfiguration);
    } else {
      _getTokenOIDCAction(success.oidcConfiguration);
    }
  }

  void _getTokenOIDCAction(OIDCConfiguration config) async {
    loginState.value = LoginState(Right(LoginLoadingAction()));
    final baseUri = kIsWeb ? _parseUri(AppConfig.baseUrl) : _parseUri(_urlText);
    if (baseUri != null) {
      await _getTokenOIDCInteractor
        .execute(baseUri, config)
        .then((response) =>
          response.fold(
            (failure) {
              if (failure is GetTokenOIDCFailure) {
               loginState.value = LoginState(Left(failure));
              } else {
                loginState.value = LoginState(Left(LoginCanNotGetTokenAction()));
              }
            },
            (success) {
              if (success is GetTokenOIDCSuccess) {
                _getTokenOIDCSuccess(success, config);
              } else {
                loginState.value = LoginState(Left(LoginCanNotGetTokenAction()));
              }
            }));
    } else {
      loginState.value = LoginState(Left(LoginCanNotGetTokenAction()));
    }
  }

  void _authenticateOidcOnBrowserAction(OIDCConfiguration config) async {
    loginState.value = LoginState(Right(LoginLoadingAction()));
    final baseUri = _parseUri(AppConfig.baseUrl);
    if (baseUri != null) {
      await _authenticateOidcOnBrowserInteractor.execute(baseUri, config)
          .then((response) => response.fold(
              (failure) {
                if (failure is AuthenticateOidcOnBrowserFailure) {
                  loginState.value = LoginState(Left(failure));
                } else {
                  loginState.value = LoginState(Left(LoginCanNotAuthenticationSSOAction()));
                }
              },
              (success) {
                if (success is! AuthenticateOidcOnBrowserSuccess) {
                  loginState.value = LoginState(Left(LoginCanNotAuthenticationSSOAction()));
                }
              }));
    } else {
      loginState.value = LoginState(Left(LoginCanNotAuthenticationSSOAction()));
    }
  }

  void _getTokenOIDCSuccess(GetTokenOIDCSuccess success, OIDCConfiguration config) {
    log('LoginController::_getTokenOIDCSuccess(): ${success.tokenOIDC.toString()}');
    loginState.value = LoginState(Right(success));
    _dynamicUrlInterceptors.changeBaseUrl(kIsWeb ? AppConfig.baseUrl : _urlText);
    _authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: success.tokenOIDC.toToken(),
        newConfig: config);
    pushAndPop(AppRoutes.SESSION);
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
    _authorizationInterceptors.setBasicAuthorization(_userNameText, _passwordText);
    pushAndPop(AppRoutes.SESSION);
  }

  void _loginFailureAction(FeatureFailure failure) {
    logError('LoginController::_loginFailureAction(): $failure');
    loginState.value = LoginState(Left(failure));
  }

  void formatUrl(String url) {
    log('LoginController::formatUrl(): $url');
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