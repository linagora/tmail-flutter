import 'dart:async';

import 'package:core/presentation/extensions/url_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/model/login_constants.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/dns_lookup_to_get_jmap_url_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_url_latest_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_username_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/sign_in_with_applicative_token_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/update_authentication_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/dns_lookup_to_get_jmap_url_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/sign_in_with_applicative_token_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/starting_page/domain/state/sign_in_twake_workplace_state.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_in_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
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
  final DNSLookupToGetJmapUrlInteractor _dnsLookupToGetJmapUrlInteractor;
  final SignInTwakeWorkplaceInteractor _signInTwakeWorkplaceInteractor;
  final SignInWithApplicativeTokenInteractor _signInWithApplicativeTokenInteractor;

  final TextEditingController urlInputController = TextEditingController();
  final TextEditingController usernameInputController = TextEditingController();
  final TextEditingController passwordInputController = TextEditingController();
  final FocusNode baseUrlFocusNode = FocusNode();
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode passFocusNode = FocusNode();

  final loginFormType = LoginFormType.none.obs;

  OIDCResponse? _oidcResponse;
  UserName? _username;
  Password? _password;
  Uri? _baseUri;
  String _applicativeToken = '';
  bool get isShowingMessage {
    return viewState.value.fold(
      (failure) {
        // Ignore message when login by applicative token
        if (failure is UpdateAccountCacheFailure && _password == null && _applicativeToken.isNotEmpty) {
          return false;
        }

        return true;
      },
      (success) => true
    );
  }

  DeepLinksManager? _deepLinksManager;
  StreamSubscription<DeepLinkData?>? _deepLinkDataStreamSubscription;

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
    this._dnsLookupToGetJmapUrlInteractor,
    this._signInTwakeWorkplaceInteractor,
    this._signInWithApplicativeTokenInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    if (PlatformInfo.isMobile) {
      _registerDeepLinks();
    }
  }

  @override
  void onReady() {
    super.onReady();
    final arguments = Get.arguments;
    if (arguments is LoginArguments) {
      if (arguments.loginFormType == LoginFormType.passwordForm) {
        loginFormType.value = LoginFormType.dnsLookupForm;
      } else {
        loginFormType.value = arguments.loginFormType;
      }
      if (PlatformInfo.isWeb) {
        _checkOIDCIsAvailable();
      }
    } else {
      if (PlatformInfo.isWeb) {
        _getAuthenticationInfo();
      }
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('LoginController::handleFailureViewState(): $failure');
    if (failure is GetAuthenticationInfoFailure) {
      getAuthenticatedAccountAction();
    } else if (failure is CheckOIDCIsAvailableFailure) {
      _handleCheckOIDCIsAvailableFailure(failure);
    } else if (failure is GetStoredOidcConfigurationFailure ||
        failure is GetOIDCIsAvailableFailure ||
        failure is GetOIDCConfigurationFailure ||
        failure is SignInTwakeWorkplaceFailure
    ) {
      _handleCommonOIDCFailure();
    } else if (failure is GetTokenOIDCFailure) {
      _handleNoSuitableBrowserOIDC(failure)
        .map((stillFailed) => _handleCommonOIDCFailure());
    } else if (failure is GetAuthenticatedAccountFailure) {
      _checkOIDCIsAvailable();
    } else if (failure is GetSessionFailure) {
      SmartDialog.dismiss();
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
    } else if (success is DNSLookupToGetJmapUrlSuccess) {
      _handleDNSLookupToGetJmapUrlSuccess(success);
    } else if (success is SignInTwakeWorkplaceSuccess) {
      _synchronizeTokenAndGetSession(
        baseUri: success.baseUri,
        tokenOIDC: success.tokenOIDC,
        oidcConfiguration: success.oidcConfiguration,
      );
    } else if (success is SignInWithApplicativeTokenSuccess) {
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
  void handleUrgentException({Failure? failure, Exception? exception}) {
    logError('LoginController::handleUrgentException:Exception: $exception | Failure: $failure');
    if (failure is CheckOIDCIsAvailableFailure) {
      _handleCheckOIDCIsAvailableFailure(failure);
    } else if (failure is GetStoredOidcConfigurationFailure ||
        failure is GetOIDCConfigurationFailure ||
        failure is GetOIDCIsAvailableFailure ||
        failure is SignInTwakeWorkplaceFailure
    ) {
      _handleCommonOIDCFailure();
    } else if (failure is GetTokenOIDCFailure) {
      _handleNoSuitableBrowserOIDC(failure)
        .map((stillFailed) => _handleCommonOIDCFailure());
    } else if (failure is GetSessionFailure) {
      SmartDialog.dismiss();
      clearAllData();
    } else {
      super.handleUrgentException(failure: failure, exception: exception);
    }
  }

  @override
  void handleReloaded(Session session) {
    SmartDialog.dismiss();

    popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: session,
    );
  }

  void _registerDeepLinks() {
    _deepLinksManager = getBinding<DeepLinksManager>();
    _deepLinksManager?.clearPendingDeepLinkData();
    _deepLinkDataStreamSubscription = _deepLinksManager
        ?.pendingDeepLinkData.stream
        .listen(_handlePendingDeepLinkDataStream);
  }

  void _handlePendingDeepLinkDataStream(DeepLinkData? deepLinkData) {
    log('LoginController::_handlePendingDeepLinkDataStream:DeepLinkData = $deepLinkData');
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

  void _handleCheckOIDCIsAvailableFailure(CheckOIDCIsAvailableFailure failure) {
    if (failure.exception is CanNotFoundOIDCLinks || failure.exception is InvalidOIDCResponseException) {
      _handleCommonOIDCFailure();
    } else {
      loginFormType.value = LoginFormType.retry;
    }
  }

  void retryCheckOidc() {
    if (PlatformInfo.isMobile) {
      loginFormType.value = LoginFormType.dnsLookupForm;
    } else {
      loginFormType.value = LoginFormType.none;
    }
    _checkOIDCIsAvailable();
  }

  void _getAuthenticationInfo() {
    consumeState(_getAuthenticationInfoInteractor.execute());
  }

  void _getStoredOidcConfiguration() {
    consumeState(_getStoredOidcConfigurationInteractor.execute());
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

  void _redirectToSSOLoginScreen(CheckOIDCIsAvailableSuccess success) {
    _oidcResponse = success.oidcResponse;
    consumeState(_getOIDCIsAvailableInteractor.execute(
      OIDCRequest(
        baseUrl: _currentBaseUrl!.toString(),
        resourceUrl: _currentBaseUrl!.origin
      )
    ));
  }

  void handleBackButtonAction(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    clearState();
    switch(loginFormType.value) {
      case LoginFormType.dnsLookupForm:
      case LoginFormType.baseUrlForm:
        navigateToTwakeWelcomePage();
        break;
      case LoginFormType.passwordForm:
        _password = null;
        _baseUri = null;
        urlInputController.clear();
        passwordInputController.clear();
        loginFormType.value = LoginFormType.dnsLookupForm;
        break;
      case LoginFormType.credentialForm:
        _password = null;
        _username = null;
        usernameInputController.clear();
        passwordInputController.clear();
        loginFormType.value = LoginFormType.baseUrlForm;
        break;
      default:
        break;
    }
  }

  void _showCredentialForm() {
    clearState();
    loginFormType.value = LoginFormType.credentialForm;
    userNameFocusNode.requestFocus();
  }

  void handleLoginPressed(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    log('LoginController::handleLoginPressed:_currentBaseUrl: $_currentBaseUrl | _username: $_username | _password: $_password');
    if (_currentBaseUrl == null) {
      consumeState(Stream.value(Left(AuthenticationUserFailure(CanNotFoundBaseUrl()))));
    } else if (_username == null && _applicativeToken.isEmpty) {
      consumeState(Stream.value(Left(AuthenticationUserFailure(CanNotFoundUserName()))));
    } else if (_password == null && _applicativeToken.isEmpty) {
      consumeState(Stream.value(Left(AuthenticationUserFailure(CanNotFoundPassword()))));
    } else {
      if (PlatformInfo.isMobile && loginFormType.value == LoginFormType.credentialForm && _username != null) {
        TextInput.finishAutofillContext();
        if (_username!.value.isEmail) {
          _storeUsernameToCache(_username!.value);
        }
      }

      if (_password != null && _username != null) {
        consumeState(
          _authenticationInteractor.execute(
            baseUrl: _currentBaseUrl!,
            userName: _username!,
            password: _password!
          )
        );
      } else {
        _loginByApplicativeToken(_applicativeToken);
      }
    }
  }

  void _getOIDCConfiguration() {
    if (_oidcResponse != null) {
      consumeState(_getOIDCConfigurationInteractor.execute(_oidcResponse!));
    } else {
      dispatchState(Left(GetOIDCConfigurationFailure(CanNotFoundOIDCLinks())));
    }
  }

  void _getOIDCConfigurationSuccess(GetOIDCConfigurationSuccess success) {
    if (PlatformInfo.isWeb) {
      _authenticateOidcOnBrowserAction(success.oidcConfiguration);
    } else if (success.oidcConfiguration.authority == AppConfig.saasRegistrationUrl) {
      _getTokenOIDCOnSaaSPlatform(success.oidcConfiguration);
    } else {
      _getTokenOIDCAction(success.oidcConfiguration);
    }
  }

  void _getTokenOIDCOnSaaSPlatform(OIDCConfiguration oidcConfiguration) {
    if (_currentBaseUrl != null) {
      consumeState(_signInTwakeWorkplaceInteractor.execute(
        baseUri: _currentBaseUrl!,
        oidcConfiguration: oidcConfiguration,
      ));
    } else {
      dispatchState(Left(GetTokenOIDCFailure(CanNotFoundBaseUrl())));
    }
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

  void _getTokenOIDCAction(OIDCConfiguration config) {
    if (_currentBaseUrl != null) {
      consumeState(_getTokenOIDCInteractor.execute(_currentBaseUrl!, config));
    } else {
      dispatchState(Left(GetTokenOIDCFailure(CanNotFoundBaseUrl())));
    }
  }

  void _authenticateOidcOnBrowserAction(OIDCConfiguration config) async {
    _removeAuthDestinationUrlInSessionStorage();

    if (_currentBaseUrl != null) {
      consumeState(_authenticateOidcOnBrowserInteractor.execute(_currentBaseUrl!, config));
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
    _synchronizeTokenAndGetSession(
      baseUri: _currentBaseUrl!,
      tokenOIDC: success.tokenOIDC,
      oidcConfiguration: success.configuration,
    );
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
    FocusManager.instance.primaryFocus?.unfocus();

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
    if (loginFormType.value == LoginFormType.retry && PlatformInfo.isMobile) {
      loginFormType.value = LoginFormType.dnsLookupForm;
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

  bool get isBackButtonActivated =>
    loginFormType.value == LoginFormType.dnsLookupForm ||
    loginFormType.value == LoginFormType.passwordForm ||
    loginFormType.value == LoginFormType.credentialForm;

  void onApplicativeTokenChange(String value) {
    _applicativeToken = value;
  }

  void _loginByApplicativeToken(String token) {
    consumeState(_signInWithApplicativeTokenInteractor.execute(
      applicativeToken: token,
      baseUri: _currentBaseUrl!,
      uuid: uuid,
    ));
  }

  @override
  void onClose() {
    passFocusNode.dispose();
    baseUrlFocusNode.dispose();
    userNameFocusNode.dispose();
    urlInputController.dispose();
    usernameInputController.dispose();
    passwordInputController.dispose();
    if (PlatformInfo.isMobile) {
      _deepLinkDataStreamSubscription?.cancel();
    }
    super.onClose();
  }
}
