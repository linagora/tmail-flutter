import 'dart:async';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
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
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/auto_sign_in_via_deep_link_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/ios_notification_manager.dart';

class HomeController extends ReloadableController {
  final CleanupEmailCacheInteractor _cleanupEmailCacheInteractor;
  final EmailReceiveManager _emailReceiveManager;
  final CleanupRecentSearchCacheInteractor _cleanupRecentSearchCacheInteractor;
  final CleanupRecentLoginUrlCacheInteractor _cleanupRecentLoginUrlCacheInteractor;
  final CleanupRecentLoginUsernameCacheInteractor _cleanupRecentLoginUsernameCacheInteractor;

  IOSNotificationManager? _iosNotificationManager;
  DeepLinksManager? _deepLinksManager;
  AutoSignInViaDeepLinkInteractor? _autoSignInViaDeepLinkInteractor;

  HomeController(
    this._cleanupEmailCacheInteractor,
    this._emailReceiveManager,
    this._cleanupRecentSearchCacheInteractor,
    this._cleanupRecentLoginUrlCacheInteractor,
    this._cleanupRecentLoginUsernameCacheInteractor,
  );

  @override
  void onInit() {
    if (PlatformInfo.isMobile) {
      _initFlutterDownloader();
      _registerReceivingFileSharing();
      _registerDeepLinks();
    }
    if (PlatformInfo.isIOS) {
      _registerNotificationClickOnIOS();
    }
    super.onInit();
  }

  @override
  void onReady() {
    _cleanupCache();
    super.onReady();
  }

  @override
  void handleReloaded(Session session) {
    pushAndPopAll(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: session);
  }

  void _initFlutterDownloader() {
    FlutterDownloader
      .initialize(debug: kDebugMode)
      .then((_) => FlutterDownloader.registerCallback(downloadCallback));
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {}

  Future<void> _cleanupCache() async {
    await HiveCacheConfig.instance.onUpgradeDatabase(cachingManager);

    await Future.wait([
      _cleanupEmailCacheInteractor.execute(EmailCleanupRule(Duration.defaultCacheInternal)),
      _cleanupRecentSearchCacheInteractor.execute(RecentSearchCleanupRule()),
      _cleanupRecentLoginUrlCacheInteractor.execute(RecentLoginUrlCleanupRule()),
      _cleanupRecentLoginUsernameCacheInteractor.execute(RecentLoginUsernameCleanupRule()),
    ], eagerError: true).then((_) => getAuthenticatedAccountAction());
  }

  void _registerReceivingFileSharing() {
    _emailReceiveManager.registerReceivingFileSharingStreamWhileAppClosed();
  }

  void _registerNotificationClickOnIOS() {
    _iosNotificationManager = getBinding<IOSNotificationManager>();
    _iosNotificationManager?.listenClickNotification();
  }

  void _registerDeepLinks() {
    _deepLinksManager = getBinding<DeepLinksManager>();
    _autoSignInViaDeepLinkInteractor = getBinding<AutoSignInViaDeepLinkInteractor>();
  }

  Future<void> _handleDeepLinksNotSignedIn() async {
    final deepLinkData = await _deepLinksManager?.getDeepLinkData();
    log('HomeController::_handleDeepLinksNotSignedIn:DeepLinkData = $deepLinkData');
    if (deepLinkData == null) {
      goToLogin();
      return;
    }

    if (deepLinkData.action.toLowerCase() == AppConfig.openAppHostDeepLink.toLowerCase()) {
      _handleOpenApp(deepLinkData);
    } else {
      goToLogin();
    }
  }

  void _handleOpenApp(DeepLinkData deepLinkData) {
    _autoSignInViaDeepLink(deepLinkData);
  }

  Future<void> _handleDeepLinksSignedIn(Success authenticationViewStateSuccess) async {
    final deepLinkData = await _deepLinksManager?.getDeepLinkData();
    log('HomeController::_handleDeepLinksSignedIn:DeepLinkData = $deepLinkData');
    if (deepLinkData == null) {
      _continueUsingTheApp(authenticationViewStateSuccess);
      return;
    }

    if (deepLinkData.action.toLowerCase() == AppConfig.openAppHostDeepLink.toLowerCase()) {
      final personalAccount = _getPersonalAccountFromViewStateSuccess(authenticationViewStateSuccess);

      if (deepLinkData.username?.isNotEmpty != true ||
          personalAccount?.userName?.value.isNotEmpty != true) {
        _continueUsingTheApp(authenticationViewStateSuccess);
        return;
      }

      if (deepLinkData.username == personalAccount?.userName?.value || currentContext == null) {
        _continueUsingTheApp(authenticationViewStateSuccess);
      } else {
        _showConfirmDialogSwitchAccount(
          username: personalAccount!.userName!.value,
          onConfirmAction: () => _handleLogOutAndSignInNewAccount(
            authenticationViewStateSuccess: authenticationViewStateSuccess,
            personalAccount: personalAccount,
            deepLinkData: deepLinkData,
          ),
          onCancelAction: () => _continueUsingTheApp(authenticationViewStateSuccess)
        );
      }
    } else {
      _continueUsingTheApp(authenticationViewStateSuccess);
    }
  }

  void _continueUsingTheApp(Success authenticationViewStateSuccess) {
    log('HomeController::_continueUsingTheApp:');
    super.handleSuccessViewState(authenticationViewStateSuccess);
  }

  PersonalAccount? _getPersonalAccountFromViewStateSuccess(Success success) {
    if (success is GetCredentialViewState) {
      return success.personalAccount;
    } else if (success is GetStoredTokenOidcSuccess) {
      return success.personalAccount;
    }
    return null;
  }

  void _showConfirmDialogSwitchAccount({
    required String username,
    required Function onConfirmAction,
    required Function onCancelAction,
  }) {
    final appLocalizations = AppLocalizations.of(currentContext!);

    showConfirmDialogAction(
      currentContext!,
      '',
      appLocalizations.yesLogout,
      title: appLocalizations.logoutConfirmation,
      alignCenter: true,
      outsideDismissible: false,
      titleActionButtonMaxLines: 1,
      titlePadding: const EdgeInsetsDirectional.only(start: 24, top: 24, end: 24, bottom: 12),
      messageStyle: const TextStyle(
        color: AppColor.colorTextBody,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      listTextSpan: [
        TextSpan(text: appLocalizations.messageConfirmationLogout),
        TextSpan(
          text: ' $username',
          style: const TextStyle(
            color: AppColor.colorTextBody,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const TextSpan(text: ' ?'),
      ],
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction
    );
  }

  void _handleLogOutAndSignInNewAccount({
    required Success authenticationViewStateSuccess,
    required PersonalAccount personalAccount,
    required DeepLinkData deepLinkData,
  }) {
    if (authenticationViewStateSuccess is GetCredentialViewState) {
      setDataToInterceptors(
        baseUrl: authenticationViewStateSuccess.baseUrl.toString(),
        userName: authenticationViewStateSuccess.userName,
        password: authenticationViewStateSuccess.password,
      );
    } else if (authenticationViewStateSuccess is GetStoredTokenOidcSuccess) {
      setDataToInterceptors(
        baseUrl: authenticationViewStateSuccess.baseUrl.toString(),
        tokenOIDC: authenticationViewStateSuccess.tokenOidc,
        oidcConfiguration: authenticationViewStateSuccess.oidcConfiguration,
      );
    }

    _getSessionActionToLogOut(
      authenticationViewStateSuccess: authenticationViewStateSuccess,
      personalAccount: personalAccount,
      deepLinkData: deepLinkData,
    );
  }

  Future<void> _getSessionActionToLogOut({
    required Success authenticationViewStateSuccess,
    required PersonalAccount personalAccount,
    required DeepLinkData deepLinkData,
  }) async {
    try {
      final sessionViewState = await getSessionInteractor.execute().last;

      sessionViewState.fold(
        (failure) => _handleGetSessionFailureToLogOut(authenticationViewStateSuccess),
        (success) => _handleGetSessionSuccessToLogOut(
          sessionViewStateSuccess: success,
          authenticationViewStateSuccess: authenticationViewStateSuccess,
          personalAccount: personalAccount,
          deepLinkData: deepLinkData,
        ),
      );
    } catch (e) {
      logError('HomeController::_getSessionActionToLogOut:Exception = $e');
      _handleGetSessionFailureToLogOut(authenticationViewStateSuccess);
    }
  }

  void _handleGetSessionSuccessToLogOut({
    required Success sessionViewStateSuccess,
    required Success authenticationViewStateSuccess,
    required PersonalAccount personalAccount,
    required DeepLinkData deepLinkData,
  }) {
    if (sessionViewStateSuccess is GetSessionSuccess) {
      logoutToSignInNewAccount(
        session: sessionViewStateSuccess.session,
        accountId: personalAccount.accountId!,
        onFailureCallback: () =>
          _continueUsingTheApp(authenticationViewStateSuccess),
        onSuccessCallback: () => _autoSignInViaDeepLink(deepLinkData),
      );
    } else {
      _continueUsingTheApp(authenticationViewStateSuccess);
    }
  }

  void _handleGetSessionFailureToLogOut(Success authenticationViewStateSuccess) {
    _continueUsingTheApp(authenticationViewStateSuccess);

    if (currentContext == null || currentOverlayContext == null) {
      return;
    }

    appToast.showToastErrorMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentContext!).notFoundSession,
    );
  }

  void _autoSignInViaDeepLink(DeepLinkData deepLinkData) {
    if (deepLinkData.isValidToken() && _autoSignInViaDeepLinkInteractor != null) {
      consumeState(_autoSignInViaDeepLinkInteractor!.execute(
        baseUri: Uri.parse(AppConfig.saasJmapServerUrl),
        tokenOIDC: deepLinkData.getTokenOIDC(),
        oidcConfiguration: OIDCConfiguration(
          authority: AppConfig.saasRegistrationUrl,
          clientId: OIDCConstant.clientId,
          scopes: AppConfig.oidcScopes,
        ),
      ));
    } else {
      goToLogin();

      if (currentContext == null || currentOverlayContext == null) {
        return;
      }

      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).tokenInvalid,
      );
    }
  }

  void _handleAutoSignInViaDeepLinkFailure() {
    goToLogin();

    if (currentContext == null || currentOverlayContext == null) {
      return;
    }

    appToast.showToastErrorMessage(
      currentOverlayContext!,
      AppLocalizations.of(currentContext!).tokenInvalid,
    );
  }

  void _handleAutoSignInViaDeepLinkSuccess(AutoSignInViaDeepLinkSuccess success) {
    setDataToInterceptors(
      baseUrl: success.baseUri.toString(),
      tokenOIDC: success.tokenOIDC,
      oidcConfiguration: success.oidcConfiguration,
    );
    getSessionAction();
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (PlatformInfo.isMobile && isNotSignedIn(failure)) {
      _handleDeepLinksNotSignedIn();
    } else if (failure is AutoSignInViaDeepLinkFailure) {
      _handleAutoSignInViaDeepLinkFailure();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (PlatformInfo.isMobile &&
        (success is GetCredentialViewState ||
            success is GetStoredTokenOidcSuccess)) {
      _handleDeepLinksSignedIn(success);
    } else if (success is AutoSignInViaDeepLinkSuccess) {
      _handleAutoSignInViaDeepLinkSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }
}