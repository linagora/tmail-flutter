import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_url_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_username_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_url_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_username_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_search_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_authenticated_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_arguments.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeController extends BaseController {
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final CleanupEmailCacheInteractor _cleanupEmailCacheInteractor;
  final EmailReceiveManager _emailReceiveManager;
  final CleanupRecentSearchCacheInteractor _cleanupRecentSearchCacheInteractor;
  final CleanupRecentLoginUrlCacheInteractor _cleanupRecentLoginUrlCacheInteractor;
  final CleanupRecentLoginUsernameCacheInteractor _cleanupRecentLoginUsernameCacheInteractor;

  HomeController(
    this._getAuthenticatedAccountInteractor,
    this._dynamicUrlInterceptors,
    this._cleanupEmailCacheInteractor,
    this._emailReceiveManager,
    this._cleanupRecentSearchCacheInteractor,
    this._cleanupRecentLoginUrlCacheInteractor,
    this._cleanupRecentLoginUsernameCacheInteractor,
  );

  PersonalAccount? currentAccount;

  @override
  void onInit() {
    if (!kIsWeb) {
      _initFlutterDownloader();
      _registerReceivingSharingIntent();
    }
    super.onInit();
  }

  @override
  void onReady() {
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
    await HiveCacheConfig().onUpgradeDatabase(cachingManager);

    await Future.wait([
      _cleanupEmailCacheInteractor.execute(EmailCleanupRule(Duration.defaultCacheInternal)),
      _cleanupRecentSearchCacheInteractor.execute(RecentSearchCleanupRule()),
      _cleanupRecentLoginUrlCacheInteractor.execute(RecentLoginUrlCleanupRule()),
      _cleanupRecentLoginUsernameCacheInteractor.execute(RecentLoginUsernameCleanupRule()),
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
        if (GetUtils.isEmail(uri.path)) {
          log('HomeController::onReady(): Address: ${uri.path}');
          _emailReceiveManager.setPendingEmailAddress(EmailAddress(null, uri.path));
        } else if (uri.scheme == "file") {
          log('HomeController::onReady(): SharedMediaFilePath: ${uri.path}');
          _emailReceiveManager.setPendingFileInfo([SharedMediaFile(uri.path, null, null, SharedMediaType.FILE)]);
        } else {
          log('HomeController::onReady(): EmailContent: ${uri.path}');
          _emailReceiveManager.setPendingEmailContent(EmailContent(EmailContentType.textPlain, Uri.decodeComponent(uri.path)));
        }
      }
    });

    _emailReceiveManager.receivingFileSharingStream.listen((listFile) {
      log('HomeController::onInit(): SharedMediaFile: ${listFile.toString()}');
      _emailReceiveManager.setPendingFileInfo(listFile);
    });
  }

  void _goToLogin({LoginArguments? arguments}) {
    popAndPush(AppRoutes.login, arguments: arguments);
  }

  @override
  void handleFailureViewState(Failure failure) async {
    super.handleFailureViewState(failure);
    if (failure is NoAuthenticatedAccountFailure ||
        failure is GetAuthenticatedAccountFailure ||
        failure is GetStoredTokenOidcFailure ||
        failure is GetCredentialFailure) {
      _goToLogin(arguments: LoginArguments(LoginFormType.baseUrlForm));
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetStoredTokenOidcSuccess) {
      _goToSessionWithTokenOidc(success);
    } else if (success is GetCredentialViewState) {
      _goToSessionWithBasicAuth(success);
    }
  }

  void _goToSessionWithTokenOidc(GetStoredTokenOidcSuccess storedTokenOidcSuccess) {
    _dynamicUrlInterceptors.setJmapUrl(storedTokenOidcSuccess.baseUrl.toString());
    _dynamicUrlInterceptors.changeBaseUrl(storedTokenOidcSuccess.baseUrl.toString());
    authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: storedTokenOidcSuccess.tokenOidc.toToken(),
        newConfig: storedTokenOidcSuccess.oidcConfiguration);
    authorizationIsolateInterceptors.setTokenAndAuthorityOidc(
        newToken: storedTokenOidcSuccess.tokenOidc.toToken(),
        newConfig: storedTokenOidcSuccess.oidcConfiguration);
    popAndPush(AppRoutes.session, arguments: _dynamicUrlInterceptors.baseUrl);
  }

  void _goToSessionWithBasicAuth(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.setJmapUrl(credentialViewState.baseUrl.origin);
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    authorizationInterceptors.setBasicAuthorization(
      credentialViewState.userName.value,
      credentialViewState.password.value,
    );
    authorizationIsolateInterceptors.setBasicAuthorization(
      credentialViewState.userName.value,
      credentialViewState.password.value,
    );
    popAndPush(AppRoutes.session, arguments: _dynamicUrlInterceptors.baseUrl);
  }
}