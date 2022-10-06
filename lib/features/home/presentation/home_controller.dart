import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_search_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeController extends BaseController {
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final AuthorizationInterceptors _authorizationInterceptors;
  final AuthorizationInterceptors _authorizationIsolateInterceptors;
  final CleanupEmailCacheInteractor _cleanupEmailCacheInteractor;
  final EmailReceiveManager _emailReceiveManager;
  final CleanupRecentSearchCacheInteractor _cleanupRecentSearchCacheInteractor;
  final DeleteCredentialInteractor _deleteCredentialInteractor;
  final CachingManager _cachingManager;
  final DeleteAuthorityOidcInteractor _deleteAuthorityOidcInteractor;
  final CheckOIDCIsAvailableInteractor _checkOIDCIsAvailableInteractor;

  HomeController(
    this._getAuthenticatedAccountInteractor,
    this._dynamicUrlInterceptors,
    this._authorizationInterceptors,
    this._authorizationIsolateInterceptors,
    this._cleanupEmailCacheInteractor,
    this._emailReceiveManager,
    this._cleanupRecentSearchCacheInteractor,
    this._deleteCredentialInteractor,
    this._cachingManager,
    this._deleteAuthorityOidcInteractor,
    this._checkOIDCIsAvailableInteractor,
  );

  Account? currentAccount;

  @override
  void onInit() {
    log('HomeController::onInit(): ');
    if (!kIsWeb) {
      _initFlutterDownloader();
      _registerReceivingSharingIntent();
    }
    super.onInit();
  }

  @override
  void onReady() {
    log('HomeController::onReady()');
    _cleanupCache();
    super.onReady();
  }

  void _initFlutterDownloader() {
    FlutterDownloader
      .initialize(debug: kDebugMode)
      .then((_) => FlutterDownloader.registerCallback(downloadCallback));
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {}

  void _cleanupCache() async {
    await Future.wait([
      _cleanupEmailCacheInteractor.execute(EmailCleanupRule(Duration.defaultCacheInternal)),
      _cleanupRecentSearchCacheInteractor.execute(RecentSearchCleanupRule())
    ]).then((value) => _getAuthenticatedAccount());
  }

  void _getAuthenticatedAccount() async {
    log('HomeController::_getAuthenticatedAccount()');
    consumeState(_getAuthenticatedAccountInteractor.execute());
  }

  void _registerReceivingSharingIntent() {
    _emailReceiveManager.receivingSharingStream.listen((uri) {
      log('HomeController::onReady(): Received Email: ${uri.toString()}');
      if (uri != null) {
        if(GetUtils.isEmail(uri.path)) {
          log('HomeController::onReady(): Address: ${uri.path}');
          _emailReceiveManager.setPendingEmailAddress(EmailAddress(null, uri.path));
        } else {
          log('HomeController::onInit(): SharedMediaFilePath: ${uri.path}');
          _emailReceiveManager.setPendingFileInfo([SharedMediaFile(uri.path, null, null, SharedMediaType.FILE)]);
        }
      }
    });

    _emailReceiveManager.receivingFileSharingStream.listen((listFile) {
      log('HomeController::onInit(): SharedMediaFile: ${listFile.toString()}');
      _emailReceiveManager.setPendingFileInfo(listFile);
    });
  }

  void _goToLogin({LoginArguments? arguments}) {
    pushAndPop(AppRoutes.LOGIN, arguments: arguments);
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.fold(_handleFailureViewState, _handleSuccessViewState);
  }

  @override
  void onDone() {}

  @override
  void onError(error) {
    _clearAllCacheAndCredential();
  }

  void _handleFailureViewState(Failure failure) async {
    logError('HomeController::_handleFailureViewState(): ${failure.toString()}');
    _clearAllCacheAndCredential();
  }

  void _handleSuccessViewState(Success success) {
    log('HomeController::_handleSuccessViewState(): $success');
    if (success is GetStoredTokenOidcSuccess) {
      _goToSessionWithTokenOidc(success);
    } else if (success is GetCredentialViewState) {
      _goToSessionWithBasicAuth(success);
    }
  }

  void _clearAllCacheAndCredential() async {
    await Future.wait([
      _deleteCredentialInteractor.execute(),
      _deleteAuthorityOidcInteractor.execute(),
      _cachingManager.clearAll()
    ]).then((value) {
      if (BuildUtils.isWeb) {
        _checkOIDCIsAvailable();
      } else {
        _goToLogin();
      }
    });
  }

  Uri? _parseUri(String? url) => url != null && url.trim().isNotEmpty
      ? Uri.parse(url.trim())
      : null;

  void _checkOIDCIsAvailable() async {
    final baseUri = _parseUri(AppConfig.baseUrl);
    log('LoginController::_checkOIDCIsAvailable(): baseUri: $baseUri');
    if (baseUri != null) {
      await _checkOIDCIsAvailableInteractor
          .execute(OIDCRequest(baseUrl: baseUri.toString(), resourceUrl: baseUri.origin))
          .then((response) => response.fold(
              (failure) => _goToLogin(arguments: LoginArguments(LoginFormType.credentialForm)),
              (success) => success is CheckOIDCIsAvailableSuccess
                  ? _goToLogin(arguments: LoginArguments(LoginFormType.ssoForm))
                  : _goToLogin(arguments: LoginArguments(LoginFormType.credentialForm))));
    } else {
      _goToLogin(arguments: LoginArguments(LoginFormType.credentialForm));
    }
  }

  void _goToSessionWithTokenOidc(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    _dynamicUrlInterceptors.changeBaseUrl(storedTokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: storedTokenOidcSuccess.tokenOidc.toToken(),
        newConfig: storedTokenOidcSuccess.oidcConfiguration);
    _authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
        newToken: storedTokenOidcSuccess.tokenOidc.toToken(),
        newConfig: storedTokenOidcSuccess.oidcConfiguration);
    pushAndPop(AppRoutes.SESSION);
  }

  void _goToSessionWithBasicAuth(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    _authorizationInterceptors.setBasicAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
    _authorizationIsolateInterceptors.setBasicAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
    pushAndPop(AppRoutes.SESSION);
  }
}