import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/extensions/url_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/password.dart';
import 'package:model/account/user_name.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/request/oidc_request.dart';
import 'package:model/oidc/response/oidc_response.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/domain/state/authenticate_oidc_on_browser_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_url_latest_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_all_recent_login_username_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authentication_info_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_authentication_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/state/login_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/network_status_handle/presentation/network_connnection_controller.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class LoginController extends ReloadableController {

  final AuthenticationInteractor _authenticationInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final AuthorizationInterceptors _authorizationInterceptors;
  final AuthorizationInterceptors _authorizationIsolateInterceptors;
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
  final NetworkConnectionController networkConnectionController = Get.find<NetworkConnectionController>();

  LoginController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    UpdateAuthenticationAccountInteractor updateAuthenticationAccountInteractor,
    this._authenticationInteractor,
    this._dynamicUrlInterceptors,
    this._authorizationInterceptors,
    this._authorizationIsolateInterceptors,
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
  ) : super(
    logoutOidcInteractor,
    deleteAuthorityOidcInteractor,
    getAuthenticatedAccountInteractor,
    updateAuthenticationAccountInteractor
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
  void onReady() {
    super.onReady();
    if (BuildUtils.isWeb) {
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
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.fold(
      (failure) {
        if (failure is GetAuthenticationInfoFailure) {
          getAuthenticatedAccountAction();
        } else if (failure is CheckOIDCIsAvailableFailure ||
            failure is GetStoredOidcConfigurationFailure) {
          _showFormLoginWithCredentialAction();
        } else if (failure is GetOIDCIsAvailableFailure) {
          loginState.value = LoginState(Left(LoginSSONotAvailableAction()));
          _showFormLoginWithCredentialAction();
        } else if (failure is AuthenticationUserFailure) {
          _loginFailureAction(failure);
        } else if (failure is GetOIDCConfigurationFailure ||
            failure is GetTokenOIDCFailure ||
            failure is AuthenticateOidcOnBrowserFailure) {
          loginState.value = LoginState(Left(failure));
        }
      },
      (success) {
        if (success is GetAuthenticationInfoSuccess) {
          _getStoredOidcConfiguration();
        } else if (success is GetStoredOidcConfigurationSuccess) {
          _getTokenOIDCAction(success.oidcConfiguration);
        } else if (success is CheckOIDCIsAvailableSuccess) {
          _showFormLoginWithSSOAction(success);
        } else if (success is GetOIDCIsAvailableSuccess) {
          loginState.value = LoginState(Right(success));
          _oidcResponse = success.oidcResponse;
          _getOIDCConfiguration();
        } else if (success is GetOIDCConfigurationSuccess) {
          _getOIDCConfigurationSuccess(success);
        } else if (success is GetTokenOIDCSuccess) {
          _getTokenOIDCSuccess(success);
        } else if (success is AuthenticationUserSuccess) {
          _loginSuccessAction(success);
        } else if (success is GetAuthenticationInfoLoading ||
            success is CheckOIDCIsAvailableLoading ||
            success is GetStoredOidcConfigurationLoading ||
            success is GetOIDCConfigurationLoading ||
            success is GetTokenOIDCLoading ||
            success is AuthenticationUserLoading ||
            success is GetOIDCIsAvailableLoading) {
          loginState.value = LoginState(Right(LoginLoadingAction()));
        }
      }
    );
  }

  @override
  void handleReloaded(Session session) {
    pushAndPop(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard, NavigationRouter()),
      arguments: session);
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
    final baseUri = BuildUtils.isWeb ? _parseUri(AppConfig.baseUrl) : _parseUri(_urlText);
    if (baseUri == null) {
      loginState.value = LoginState(Left(LoginMissUrlAction()));
    } else {
      consumeState(_checkOIDCIsAvailableInteractor.execute(OIDCRequest(
          baseUrl: baseUri.toString(),
          resourceUrl: baseUri.origin)));
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
    _saveRecentLoginUsername();
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

  void handleSSOPressed() {
    final baseUri = _parseUri(AppConfig.baseUrl);
    if (baseUri != null) {
      consumeState(_getOIDCIsAvailableInteractor.execute(OIDCRequest(
          baseUrl: baseUri.toString(),
          resourceUrl: baseUri.origin)));
    }  else {
      loginState.value = LoginState(Left(LoginCanNotAuthenticationSSOAction()));
    }
  }

  void _getOIDCConfiguration() {
    if (_oidcResponse != null) {
      consumeState(_getOIDCConfigurationInteractor.execute(_oidcResponse!));
    } else {
      loginState.value = LoginState(Left(LoginCanNotAuthenticationSSOAction()));
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
    final baseUri = kIsWeb ? _parseUri(AppConfig.baseUrl) : _parseUri(_urlText);
    if (baseUri != null) {
     consumeState(_getTokenOIDCInteractor.execute(baseUri, config));
    } else {
      loginState.value = LoginState(Left(LoginCanNotGetTokenAction()));
    }
  }

  void _authenticateOidcOnBrowserAction(OIDCConfiguration config) async {
    final baseUri = _parseUri(AppConfig.baseUrl);
    if (baseUri != null) {
      consumeState(_authenticateOidcOnBrowserInteractor.execute(baseUri, config));
    } else {
      loginState.value = LoginState(Left(LoginCanNotAuthenticationSSOAction()));
    }
  }

  void _getTokenOIDCSuccess(GetTokenOIDCSuccess success) {
    log('LoginController::_getTokenOIDCSuccess(): ${success.tokenOIDC.toString()}');
    loginState.value = LoginState(Right(success));
    _dynamicUrlInterceptors.changeBaseUrl(kIsWeb ? AppConfig.baseUrl : _urlText);
    _authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: success.tokenOIDC.toToken(),
        newConfig: success.configuration);
    _authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
        newToken: success.tokenOIDC.toToken(),
        newConfig: success.configuration);
    pushAndPop(AppRoutes.session, arguments: _dynamicUrlInterceptors.baseUrl);
  }

  void _loginAction(Uri baseUrl, UserName userName, Password password) async {
    consumeState(_authenticationInteractor.execute(baseUrl, userName, password));
  }

  void _loginSuccessAction(AuthenticationUserSuccess success) {
    loginState.value = LoginState(Right(success));
    _dynamicUrlInterceptors.changeBaseUrl(kIsWeb ? AppConfig.baseUrl : _urlText);
    _authorizationInterceptors.setBasicAuthorization(_userNameText, _passwordText);
    _authorizationIsolateInterceptors.setBasicAuthorization(_userNameText, _passwordText);
    pushAndPop(AppRoutes.session, arguments: _dynamicUrlInterceptors.baseUrl);
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

  void _saveRecentLoginUrl() {
    if (_urlText?.isNotEmpty == true && !BuildUtils.isWeb) {
      final recentLoginUrl = RecentLoginUrl.now(_urlText!);
      log('LoginController::_saveRecentLoginUrl(): $recentLoginUrl');
      consumeState(_saveLoginUrlOnMobileInteractor.execute(recentLoginUrl));
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
    if(BuildUtils.isWeb || _userNameText == null || _userNameText!.isEmpty || !_userNameText!.isEmail) {
      return ;
    }
    final recentLoginUsername = RecentLoginUsername.now(_userNameText!);
    log('LoginController::_saveRecentLoginUsername(): $recentLoginUsername');
    consumeState(_saveLoginUsernameOnMobileInteractor.execute(recentLoginUsername));
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

  @override
  void onClose() {
    urlInputController.clear();
    super.onClose();
  }

  @override
  void onDone() {}
}