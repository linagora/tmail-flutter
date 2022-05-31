import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/account/account.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_search_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/config/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeController extends BaseController {
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final AuthorizationInterceptors _authorizationInterceptors;
  final CleanupEmailCacheInteractor _cleanupEmailCacheInteractor;
  final EmailReceiveManager _emailReceiveManager;
  final CleanupRecentSearchCacheInteractor _cleanupRecentSearchCacheInteractor;

  HomeController(
    this._getAuthenticatedAccountInteractor,
    this._dynamicUrlInterceptors,
    this._authorizationInterceptors,
    this._cleanupEmailCacheInteractor,
    this._emailReceiveManager,
    this._cleanupRecentSearchCacheInteractor,
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
        log('HomeController::onReady(): Address: ${uri.path}');
        _emailReceiveManager.setPendingEmailAddress(EmailAddress(null, uri.path));
      }
    });
  }

  void _goToLogin() {
    pushAndPop(AppRoutes.LOGIN);
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
    _goToLogin();
  }

  void _handleFailureViewState(Failure failure) {
    logError('HomeController::_handleFailureViewState(): ${failure.toString()}');
    _goToLogin();
  }

  void _handleSuccessViewState(Success success) {
    log('HomeController::_handleSuccessViewState(): $success');
    if (success is GetStoredTokenOidcSuccess) {
      _goToSessionWithTokenOidc(success);
    } else if (success is GetCredentialViewState) {
      _goToSessionWithBasicAuth(success);
    }
  }

  void _goToSessionWithTokenOidc(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    _dynamicUrlInterceptors.changeBaseUrl(storedTokenOidcSuccess.baseUrl.toString());
    _authorizationInterceptors.setToken(storedTokenOidcSuccess.tokenOidc.toToken());
    pushAndPop(AppRoutes.SESSION);
  }

  void _goToSessionWithBasicAuth(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    _authorizationInterceptors.changeAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
    pushAndPop(AppRoutes.SESSION);
  }
}