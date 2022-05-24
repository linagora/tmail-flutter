import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_search_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_credential_interactor.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeController extends GetxController {
  final GetCredentialInteractor _getCredentialInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;
  final AuthorizationInterceptors _authorizationInterceptors;
  final CleanupEmailCacheInteractor _cleanupEmailCacheInteractor;
  final EmailReceiveManager _emailReceiveManager;
  final CleanupRecentSearchCacheInteractor _cleanupRecentSearchCacheInteractor;

  HomeController(
    this._getCredentialInteractor,
    this._dynamicUrlInterceptors,
    this._authorizationInterceptors,
    this._cleanupEmailCacheInteractor,
    this._emailReceiveManager,
    this._cleanupRecentSearchCacheInteractor,
  );

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
    ]).then((value) => _getCredentialAction());
  }

  void _getCredentialAction() async {
    await _getCredentialInteractor.execute()
      .then((response) => response.fold(
        (failure) => _goToLogin(),
        (success) => success is GetCredentialViewState ? _goToMailbox(success) : _goToLogin()));
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

  void _goToMailbox(GetCredentialViewState credentialViewState) {
    _dynamicUrlInterceptors.changeBaseUrl(credentialViewState.baseUrl.origin);
    _authorizationInterceptors.changeAuthorization(
      credentialViewState.userName.userName,
      credentialViewState.password.value,
    );
    pushAndPop(AppRoutes.SESSION);
  }
}