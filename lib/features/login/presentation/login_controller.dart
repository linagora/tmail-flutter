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
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/model/login_constants.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/dns_lookup_to_get_jmap_url_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_url_latest_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_username_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_auth_response_url_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_current_account_cache_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/dns_lookup_to_get_jmap_url_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_auth_response_url_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:universal_html/html.dart' as html;

class LoginController extends ReloadableController {

  final AuthenticationInteractor _authenticationInteractor;
  final CheckOIDCIsAvailableInteractor _checkOIDCIsAvailableInteractor;
  final GetTokenOIDCInteractor _getTokenOIDCInteractor;
  final AuthenticateOidcOnBrowserInteractor _authenticateOidcOnBrowserInteractor;
  final GetAuthResponseUrlBrowserInteractor _getAuthResponseUrlBrowserInteractor;
  final SaveLoginUrlOnMobileInteractor _saveLoginUrlOnMobileInteractor;
  final GetAllRecentLoginUrlOnMobileInteractor _getAllRecentLoginUrlOnMobileInteractor;
  final SaveLoginUsernameOnMobileInteractor _saveLoginUsernameOnMobileInteractor;
  final GetAllRecentLoginUsernameOnMobileInteractor _getAllRecentLoginUsernameOnMobileInteractor;
  final DNSLookupToGetJmapUrlInteractor _dnsLookupToGetJmapUrlInteractor;

  final TextEditingController urlInputController = TextEditingController();
  final TextEditingController usernameInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final FocusNode baseUrlFocusNode = FocusNode();
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode passFocusNode = FocusNode();

  final loginFormType = LoginFormType.none.obs;

  OIDCConfiguration? _oidcConfiguration;
  UserName? _username;
  Password? _password;
  Uri? _baseUri;

  LoginController(
    this._authenticationInteractor,
    this._checkOIDCIsAvailableInteractor,
    this._getTokenOIDCInteractor,
    this._authenticateOidcOnBrowserInteractor,
    this._getAuthResponseUrlBrowserInteractor,
    this._saveLoginUrlOnMobileInteractor,
    this._getAllRecentLoginUrlOnMobileInteractor,
    this._saveLoginUsernameOnMobileInteractor,
    this._getAllRecentLoginUsernameOnMobileInteractor,
    this._dnsLookupToGetJmapUrlInteractor,
  );

  @override
  void onReady() {
    super.onReady();
    final arguments = Get.arguments;
    if (arguments is LoginArguments) {
      loginFormType.value = arguments.loginFormType == LoginFormType.passwordForm
        ? LoginFormType.dnsLookupForm
        : arguments.loginFormType;

      if (PlatformInfo.isWeb) {
        _checkOIDCIsAvailable();
      }
    } else if (PlatformInfo.isWeb) {
      _handleAuthenticationSSOBrowserCallbackAction();
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('LoginController::handleFailureViewState(): $failure');
    if (failure is GetAuthResponseUrlBrowserFailure) {
      getCurrentAccountCache();
    } else if (failure is CheckOIDCIsAvailableFailure
        || failure is GetOIDCConfigurationFailure
    ) {
      _handleCommonOIDCFailure();
    } else if (failure is GetTokenOIDCFailure) {
      _handleNoSuitableBrowserOIDC(failure)
        .map((stillFailed) => _handleCommonOIDCFailure());
    } else if (failure is GetCurrentAccountCacheFailure) {
      _checkOIDCIsAvailable();
    } else if (failure is GetSessionFailure) {
      clearAllData();
    } else if (failure is DNSLookupToGetJmapUrlFailure) {
      _username = null;
      _clearTextInputField();
      _showBaseUrlForm();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetAuthResponseUrlBrowserSuccess) {
      if (_oidcConfiguration != null && _currentBaseUrl != null) {
        _getTokenOIDCAction(_oidcConfiguration!, _currentBaseUrl!.toString());
      } else {
        _showCredentialForm();
      }
    } else if (success is CheckOIDCIsAvailableSuccess) {
      _handleWhenOIDCIsAvailable(success.oidcResponse, success.baseUrl);
    } else if (success is GetTokenOIDCSuccess) {
      setUpInterceptors(success.personalAccount);
      getSessionAction();
    } else if (success is AuthenticationUserSuccess) {
      _loginSuccessAction(success);
    } else if (success is DNSLookupToGetJmapUrlSuccess) {
      _handleDNSLookupToGetJmapUrlSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleExceptionAction({Failure? failure, Exception? exception}) {
    logError('LoginController::handleExceptionAction:exception: $exception | failure: ${failure.runtimeType}');
    if (failure is CheckOIDCIsAvailableFailure ||
        failure is GetOIDCConfigurationFailure) {
      _handleCommonOIDCFailure();
    } else if (failure is GetTokenOIDCFailure) {
      _handleNoSuitableBrowserOIDC(failure)
        .map((stillFailed) => _handleCommonOIDCFailure());
    } else if (failure is GetSessionFailure) {
      clearAllData();
    } else {
      super.handleExceptionAction(failure: failure, exception: exception);
    }
  }

  @override
  void handleReloaded(Session session) {
    popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: session
    );
  }

  void _handleAuthenticationSSOBrowserCallbackAction() {
    consumeState(_getAuthResponseUrlBrowserInteractor.execute());
  }

  void handleNextInUrlInputFormPress() {
    if (PlatformInfo.isMobile && _currentBaseUrl != null) {
      _storeBaseUrlToCache(_currentBaseUrl!);
    }
    _checkOIDCIsAvailable();
  }

  void _checkOIDCIsAvailable() {
    if (_currentBaseUrl == null) {
      dispatchState(Left(CheckOIDCIsAvailableFailure(CanNotFoundBaseUrl())));
    } else {
      consumeState(_checkOIDCIsAvailableInteractor.execute(
        OIDCRequest(
          baseUrl: _currentBaseUrl!.toString(),
          resourceUrl: _currentBaseUrl!.origin
        )
      ));
    }
  }

  void handleBackButtonAction() {
    clearState();
    if (loginFormType.value == LoginFormType.credentialForm) {
      _password = null;
      _username = null;
      usernameInputController.clear();
      passwordInputController.clear();
      loginFormType.value = LoginFormType.baseUrlForm;
    } else if (loginFormType.value == LoginFormType.passwordForm) {
      _password = null;
      _baseUri = null;
      urlInputController.clear();
      passwordInputController.clear();
      loginFormType.value = LoginFormType.dnsLookupForm;
    }
  }

  void _showCredentialForm() {
    clearState();
    loginFormType.value = LoginFormType.credentialForm;
    userNameFocusNode.requestFocus();
  }

  void handleLoginPressed() {
    log('LoginController::handleLoginPressed:_currentBaseUrl: $_currentBaseUrl | _username: $_username | _password: $_password');
    if (_currentBaseUrl == null) {
      consumeState(Stream.value(Left(AuthenticationUserFailure(CanNotFoundBaseUrl()))));
    } else if (_username == null) {
      consumeState(Stream.value(Left(AuthenticationUserFailure(CanNotFoundUserName()))));
    } else if (_password == null) {
      consumeState(Stream.value(Left(AuthenticationUserFailure(CanNotFoundPassword()))));
    } else {
      if (PlatformInfo.isMobile && loginFormType.value == LoginFormType.credentialForm) {
        TextInput.finishAutofillContext();
        if (_username!.value.isEmail) {
          _storeUsernameToCache(_username!.value);
        }
      }

      consumeState(
        _authenticationInteractor.execute(
          baseUrl: _currentBaseUrl!,
          userName: _username!,
          password: _password!
        )
      );
    }
  }

  void _handleWhenOIDCIsAvailable(OIDCResponse oidcResponse, String baseUrl) {
    if (oidcResponse.links.isEmpty) {
      dispatchState(Left(GetOIDCConfigurationFailure(CanNotFoundOIDCAuthority())));
      return;
    }

    _oidcConfiguration = OIDCConfiguration(
      authority: oidcResponse.links[0].href.toString(),
      clientId: OIDCConstant.clientId,
      scopes: AppConfig.oidcScopes
    );

    if (PlatformInfo.isWeb) {
      _authenticateOidcOnBrowserAction(_oidcConfiguration!, baseUrl);
    } else {
      _getTokenOIDCAction(_oidcConfiguration!, baseUrl);
    }
  }

  void _getTokenOIDCAction(OIDCConfiguration config, String baseUrl) {
    consumeState(_getTokenOIDCInteractor.execute(baseUrl, config));
  }

  void _authenticateOidcOnBrowserAction(OIDCConfiguration config, String baseUrl) {
    _removeAuthDestinationUrlInSessionStorage();
    consumeState(_authenticateOidcOnBrowserInteractor.execute(baseUrl, config));
  }

  void _removeAuthDestinationUrlInSessionStorage() {
    final authDestinationUrlExist = html.window.sessionStorage.containsKey(LoginConstants.AUTH_DESTINATION_KEY);
    if (authDestinationUrlExist) {
      html.window.sessionStorage.remove(LoginConstants.AUTH_DESTINATION_KEY);
    }
  }

  void _loginSuccessAction(AuthenticationUserSuccess success) {
    dynamicUrlInterceptors.setJmapUrl(_currentBaseUrl?.toString());
    dynamicUrlInterceptors.changeBaseUrl(_currentBaseUrl?.toString());
    authorizationInterceptors.setBasicAuthorization(_username!, _password!);
    authorizationIsolateInterceptors.setBasicAuthorization(_username!, _password!);
    getSessionAction();
  }

  void selectBaseUrlFromSuggestion(String url) {
    final validUrl = url.isValid() ? url.removePrefix() : url;
    log('LoginController::selectBaseUrlFromSuggestion:validUrl: $validUrl');
    urlInputController.text = validUrl;
    onBaseUrlChange(validUrl);
  }

  void _storeBaseUrlToCache(Uri uri) {
    log('LoginController::_storeBaseUrlToCache:uri: $uri');
    _saveLoginUrlOnMobileInteractor.execute(RecentLoginUrl.now(uri.toString()));
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

  void selectUsernameFromSuggestion(RecentLoginUsername recentLoginUsername) {
    log('LoginController::selectUsernameFromSuggestion():recentLoginUsername: $recentLoginUsername');
    usernameInputController.text = recentLoginUsername.username;
    _username = UserName(recentLoginUsername.username);

    if (loginFormType.value == LoginFormType.credentialForm) {
      passFocusNode.requestFocus();
    }
  }

  void _storeUsernameToCache(String userName) {
    log('LoginController::_storeUsername():userName: $userName');
    _saveLoginUsernameOnMobileInteractor.execute(RecentLoginUsername.now(userName));
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

  Uri? get _currentBaseUrl => PlatformInfo.isWeb
    ? Uri.tryParse(AppConfig.baseUrl)
    : _baseUri;

  void invokeDNSLookupToGetJmapUrl() {
    log('LoginController::invokeDNSLookupToGetJmapUrl:_username $_username');
    if (_username == null) {
      consumeState(Stream.value(Left(AuthenticationUserFailure(CanNotFoundUserName()))));
    } else {
      if (_username!.value.isEmail) {
        _storeUsernameToCache(_username!.value);
        consumeState(_dnsLookupToGetJmapUrlInteractor.execute(_username!.value));
      } else {
        _username = null;
        _clearTextInputField();
        _showBaseUrlForm();
      }
    }
  }

  void _handleDNSLookupToGetJmapUrlSuccess(DNSLookupToGetJmapUrlSuccess success) {
    onBaseUrlChange(success.jmapUrl);
    _checkOIDCIsAvailable();
  }

  void _handleCommonOIDCFailure() {
    if (PlatformInfo.isMobile && loginFormType.value == LoginFormType.dnsLookupForm) {
      _showPasswordForm();
    } else {
      _showCredentialForm();
    }
  }

  Option<Failure> _handleNoSuitableBrowserOIDC(GetTokenOIDCFailure failure) {
    if (failure.exception is NoSuitableBrowserForOIDCException) {
      return const None();
    } else {
      return Some(failure);
    }
  }

  void _showBaseUrlForm() {
    clearState();
    loginFormType.value = LoginFormType.baseUrlForm;
    baseUrlFocusNode.requestFocus();
  }

  void _showPasswordForm() {
    clearState();
    loginFormType.value = LoginFormType.passwordForm;
    passFocusNode.requestFocus();
  }

  void onUsernameChange(String value) {
    if (value.isEmpty) {
      _username = null;
    } else {
      _username = UserName(value);
    }
  }

  void onPasswordChange(String value) {
    if (value.isEmpty) {
      _password = null;
    } else {
      _password = Password(value);
    }
  }

  void onBaseUrlChange(String value) {
    if (value.isEmpty) {
      _baseUri = null;
    } else {
      if (value.isValid()) {
        log('LoginController::onBaseUrlChange:value: $value');
        urlInputController.text = value.removePrefix();
      }
      _baseUri = Uri.tryParse(value.formatURLValid());
    }
  }

  void _clearTextInputField() {
    urlInputController.clear();
    usernameInputController.clear();
    passwordInputController.clear();
  }

  @override
  void onClose() {
    passFocusNode.dispose();
    baseUrlFocusNode.dispose();
    userNameFocusNode.dispose();
    urlInputController.dispose();
    usernameInputController.dispose();
    passwordInputController.dispose();
    _oidcConfiguration = null;
    _username = null;
    _password = null;
    _baseUri = null;
    super.onClose();
  }
}