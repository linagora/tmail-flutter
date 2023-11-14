import 'package:core/presentation/extensions/url_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/model/login_constants.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_url_latest_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_username_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:universal_html/html.dart' as html;

class LoginController extends ReloadableController {

  final AuthenticationInteractor _authenticationInteractor;
  final CheckOIDCIsAvailableInteractor _checkOIDCIsAvailableInteractor;
  final GetOIDCIsAvailableInteractor _getOIDCIsAvailableInteractor;
  final GetOIDCConfigurationInteractor _getOIDCConfigurationInteractor;
  final GetTokenOIDCInteractor _getTokenOIDCInteractor;
  final AuthenticateOidcOnBrowserInteractor _authenticateOidcOnBrowserInteractor;
  final GetAuthenticationInfoInteractor _getAuthenticationInfoInteractor;
  final GetStoredOidcConfigurationInteractor _getStoredOidcConfigurationInteractor;
  final SaveLoginUrlOnMobileInteractor _saveLoginUrlOnMobileInteractor;
  final GetAllRecentLoginUrlOnMobileInteractor _getAllRecentLoginUrlOnMobileInteractor;
  final SaveLoginUsernameOnMobileInteractor _saveLoginUsernameOnMobileInteractor;
  final GetAllRecentLoginUsernameOnMobileInteractor _getAllRecentLoginUsernameOnMobileInteractor;

  final TextEditingController urlInputController = TextEditingController();
  final TextEditingController usernameInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final FocusNode passFocusNode = FocusNode();

  LoginController(
    this._authenticationInteractor,
    this._checkOIDCIsAvailableInteractor,
    this._getOIDCIsAvailableInteractor,
    this._getOIDCConfigurationInteractor,
    this._getTokenOIDCInteractor,
    this._authenticateOidcOnBrowserInteractor,
    this._getAuthenticationInfoInteractor,
    this._getStoredOidcConfigurationInteractor,
    this._saveLoginUrlOnMobileInteractor,
    this._getAllRecentLoginUrlOnMobileInteractor,
    this._saveLoginUsernameOnMobileInteractor,
    this._getAllRecentLoginUsernameOnMobileInteractor,
  );

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
  void onReady() {
    super.onReady();
    if (PlatformInfo.isWeb) {
      final arguments = Get.arguments;
      if (arguments is LoginArguments) {
        loginFormType.value = arguments.loginFormType;
        _checkOIDCIsAvailable();
      } else {
        _getAuthenticationInfo();
      }
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetAuthenticationInfoFailure) {
      getAuthenticatedAccountAction();
    } else if (failure is CheckOIDCIsAvailableFailure ||
        failure is GetStoredOidcConfigurationFailure ||
        failure is GetOIDCIsAvailableFailure ||
        failure is GetTokenOIDCFailure) {
      _showFormLoginWithCredentialAction();
    } else if (failure is GetAuthenticatedAccountFailure) {
      _checkOIDCIsAvailable();
    } else if (failure is GetSessionFailure) {
      clearAllData();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAuthenticationInfoSuccess) {
      _getStoredOidcConfiguration();
    } else if (success is GetStoredOidcConfigurationSuccess) {
      _getTokenOIDCAction(success.oidcConfiguration);
    } else if (success is CheckOIDCIsAvailableSuccess) {
      _redirectToSSOLoginScreen(success);
    } else if (success is GetOIDCIsAvailableSuccess) {
      _oidcResponse = success.oidcResponse;
      _getOIDCConfiguration();
    } else if (success is GetOIDCConfigurationSuccess) {
      _getOIDCConfigurationSuccess(success);
    } else if (success is GetTokenOIDCSuccess) {
      _getTokenOIDCSuccess(success);
    } else if (success is AuthenticationUserSuccess) {
      _loginSuccessAction(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleExceptionAction({Failure? failure, Exception? exception}) {
    super.handleExceptionAction(failure: failure, exception: exception);
    if (failure is CheckOIDCIsAvailableFailure ||
        failure is GetStoredOidcConfigurationFailure ||
        failure is GetOIDCIsAvailableFailure ||
        failure is GetTokenOIDCFailure) {
      _showFormLoginWithCredentialAction();
    } else {
      clearState();
    }
  }

  @override
  void handleReloaded(Session session) {
    popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard, NavigationRouter()),
      arguments: session
    );
  }

  void _getAuthenticationInfo() {
    consumeState(_getAuthenticationInfoInteractor.execute());
  }

  void _getStoredOidcConfiguration() {
    consumeState(_getStoredOidcConfigurationInteractor.execute());
  }

  void handleNextInUrlInputFormPress() {
    _saveRecentLoginUrl();
    _checkOIDCIsAvailable();
  }

  void _checkOIDCIsAvailable() {
    final baseUrl = _getBaseUrl();
    if (baseUrl == null) {
      dispatchState(Left(CheckOIDCIsAvailableFailure(CanNotFoundBaseUrl())));
    } else {
      consumeState(_checkOIDCIsAvailableInteractor.execute(
        OIDCRequest(
          baseUrl: baseUrl.toString(),
          resourceUrl: baseUrl.origin
        )
      ));
    }
  }

  void _redirectToSSOLoginScreen(CheckOIDCIsAvailableSuccess success) {
    _oidcResponse = success.oidcResponse;
    handleSSOPressed();
  }

  void handleBackInCredentialForm() {
    clearState();
    loginFormType.value = LoginFormType.baseUrlForm;
  }

  void _showFormLoginWithCredentialAction() {
    clearState();
    loginFormType.value = LoginFormType.credentialForm;
  }

  void handleLoginPressed() {
    TextInput.finishAutofillContext();

    _saveRecentLoginUsername();
    log('LoginController::handleLoginPressed(): ${loginFormType.value}');
    if (loginFormType.value == LoginFormType.ssoForm) {
      _getOIDCConfiguration();
    } else {
      final baseUrl = _getBaseUrl();
      final userName = _parseUserName(_userNameText);
      final password = _parsePassword(_passwordText);

      _loginAction(baseUrl: baseUrl, userName: userName, password: password);
    }
  }

  void handleSSOPressed() {
    final baseUrl = _getBaseUrl();
    if (baseUrl != null) {
      consumeState(_getOIDCIsAvailableInteractor.execute(
        OIDCRequest(
          baseUrl: baseUrl.toString(),
          resourceUrl: baseUrl.origin
        )
      ));
    } else {
      dispatchState(Left(GetOIDCIsAvailableFailure(CanNotFoundBaseUrl())));
    }
  }

  void _getOIDCConfiguration() {
    if (_oidcResponse != null) {
      consumeState(_getOIDCConfigurationInteractor.execute(_oidcResponse!));
    } else {
      dispatchState(Left(GetOIDCIsAvailableFailure(CanNotFoundOIDCLinks())));
    }
  }

  void _getOIDCConfigurationSuccess(GetOIDCConfigurationSuccess success) {
    log('LoginController::_getOIDCConfigurationSuccess():success: $success');
    if (PlatformInfo.isWeb) {
      _authenticateOidcOnBrowserAction(success.oidcConfiguration);
    } else {
      _getTokenOIDCAction(success.oidcConfiguration);
    }
  }

  void _getTokenOIDCAction(OIDCConfiguration config) async {
    final baseUri = _getBaseUrl();
    if (baseUri != null) {
      consumeState(_getTokenOIDCInteractor.execute(baseUri, config));
    } else {
      dispatchState(Left(GetTokenOIDCFailure(CanNotFoundBaseUrl())));
    }
  }

  void _authenticateOidcOnBrowserAction(OIDCConfiguration config) async {
    _removeAuthDestinationUrlInSessionStorage();

    final baseUri = _parseUri(AppConfig.baseUrl);
    if (baseUri != null) {
      consumeState(_authenticateOidcOnBrowserInteractor.execute(baseUri, config));
    } else {
      dispatchState(Left(AuthenticateOidcOnBrowserFailure(CanNotFoundBaseUrl())));
    }
  }

  void _removeAuthDestinationUrlInSessionStorage() {
    final authDestinationUrlExist = html.window.sessionStorage.containsKey(LoginConstants.AUTH_DESTINATION_KEY);
    if (authDestinationUrlExist) {
      html.window.sessionStorage.remove(LoginConstants.AUTH_DESTINATION_KEY);
    }
  }

  void _getTokenOIDCSuccess(GetTokenOIDCSuccess success) {
    log('LoginController::_getTokenOIDCSuccess(): ${success.tokenOIDC.toString()}');
    dynamicUrlInterceptors.setJmapUrl(_getBaseUrl().toString());
    dynamicUrlInterceptors.changeBaseUrl(_getBaseUrl().toString());
    authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: success.tokenOIDC.toToken(),
        newConfig: success.configuration);
    authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
        newToken: success.tokenOIDC.toToken(),
        newConfig: success.configuration);
    getSessionAction();
  }

  void _loginAction({Uri? baseUrl, UserName? userName, Password? password}) {
    consumeState(_authenticationInteractor.execute(
      baseUrl: baseUrl,
      userName: userName,
      password: password
    ));
  }

  void _loginSuccessAction(AuthenticationUserSuccess success) {
    dynamicUrlInterceptors.setJmapUrl(_getBaseUrl().toString());
    dynamicUrlInterceptors.changeBaseUrl(_getBaseUrl().toString());
    authorizationInterceptors.setBasicAuthorization(_userNameText, _passwordText);
    authorizationIsolateInterceptors.setBasicAuthorization(_userNameText, _passwordText);
    getSessionAction();
  }

  void formatUrl(String url) {
    log('LoginController::formatUrl(): $url');
    if (url.isValid()) {
      urlInputController.text = url.removePrefix();
    }
    setUrlText(urlInputController.text);
  }

  void _saveRecentLoginUrl() {
    if (_urlText?.isNotEmpty == true && PlatformInfo.isMobile) {
      final recentLoginUrl = RecentLoginUrl.now(_urlText!);
      log('LoginController::_saveRecentLoginUrl(): $recentLoginUrl');
      _saveLoginUrlOnMobileInteractor.execute(recentLoginUrl);
    }
  }

  Future<List<RecentLoginUrl>> getAllRecentLoginUrlAction(String pattern) async {
    return await _getAllRecentLoginUrlOnMobileInteractor
        .execute(pattern: pattern)
        .then((result) => result.fold(
            (failure) => <RecentLoginUrl>[],
            (success) => success is GetAllRecentLoginUrlLatestSuccess
                ? success.listRecentLoginUrl
                : <RecentLoginUrl>[]
        ));
  }

  void setUsername(String username) {
    log('LoginController::formatUsername(): $username');
    usernameInputController.text = username;
    setUserNameText(usernameInputController.text);
  }

  void _saveRecentLoginUsername() {
    if(PlatformInfo.isWeb || _userNameText == null || _userNameText!.isEmpty || !_userNameText!.isEmail) {
      return ;
    }
    final recentLoginUsername = RecentLoginUsername.now(_userNameText!);
    log('LoginController::_saveRecentLoginUsername(): $recentLoginUsername');
    _saveLoginUsernameOnMobileInteractor.execute(recentLoginUsername);
  }

  Future<List<RecentLoginUsername>> getAllRecentLoginUsernameAction(String pattern) async {
    return await _getAllRecentLoginUsernameOnMobileInteractor
        .execute(pattern: pattern)
        .then((result) => result.fold(
            (failure) => <RecentLoginUsername>[],
            (success) => success is GetAllRecentLoginUsernameLatestSuccess
                ? success.listRecentLoginUsername
                : <RecentLoginUsername>[]
        ));
  }

  Uri? _getBaseUrl() => PlatformInfo.isWeb ? _parseUri(AppConfig.baseUrl) : _parseUri(_urlText);

  @override
  void onClose() {
    passFocusNode.dispose();
    urlInputController.dispose();
    usernameInputController.dispose();
    passwordInputController.dispose();
    super.onClose();
  }
}