import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_url_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_username_cleanup_rule.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_url_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_username_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/presentation/extensions/handle_web_finger_to_get_token_extension.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/logout_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/check_oidc_is_available_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_credential_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_oidc_configuration_state.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/remove_auth_destination_url_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_type.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/ios_notification_manager.dart';

class HomeController extends ReloadableController {
  final CleanupEmailCacheInteractor _cleanupEmailCacheInteractor;
  final EmailReceiveManager _emailReceiveManager;
  final CleanupRecentLoginUrlCacheInteractor _cleanupRecentLoginUrlCacheInteractor;
  final CleanupRecentLoginUsernameCacheInteractor _cleanupRecentLoginUsernameCacheInteractor;
  final CheckOIDCIsAvailableInteractor checkOIDCIsAvailableInteractor;
  final GetOIDCConfigurationInteractor getOIDCConfigurationInteractor;
  final AuthenticateOidcOnBrowserInteractor authenticateOidcOnBrowserInteractor;
  final RemoveAuthDestinationUrlInteractor removeAuthDestinationUrlInteractor;

  IOSNotificationManager? _iosNotificationManager;
  DeepLinksManager? _deepLinksManager;

  HomeController(
    this._cleanupEmailCacheInteractor,
    this._emailReceiveManager,
    this._cleanupRecentLoginUrlCacheInteractor,
    this._cleanupRecentLoginUsernameCacheInteractor,
    this.checkOIDCIsAvailableInteractor,
    this.getOIDCConfigurationInteractor,
    this.authenticateOidcOnBrowserInteractor,
    this.removeAuthDestinationUrlInteractor,
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
    _handleNavigateToScreen();
    super.onReady();
  }

  @override
  void handleReloaded(Session session) {
    pushAndPopAll(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: session);
  }

  @override
  void onCancelReconnectWhenSessionExpired() {
    clearDataAndGoToLoginPage();
  }

  void _initFlutterDownloader() {
    FlutterDownloader
      .initialize(debug: kDebugMode)
      .then((_) => FlutterDownloader.registerCallback(downloadCallback));
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {}

  Future<void> _handleNavigateToScreen() async {
    await Future.delayed(2.seconds);
    final arguments = Get.arguments;
    if (arguments is LoginNavigateArguments) {
      _handleLoginNavigateArguments(arguments);
    } else {
      await _cleanupCache();
    }
  }

  Future<void> _cleanupCache() async {
    await HiveCacheConfig.instance.onUpgradeDatabase(cachingManager);

    await Future.wait([
      _cleanupEmailCacheInteractor.execute(EmailCleanupRule(Duration.defaultCacheInternal)),
      _cleanupRecentLoginUrlCacheInteractor.execute(RecentLoginUrlCleanupRule()),
      _cleanupRecentLoginUsernameCacheInteractor.execute(RecentLoginUsernameCleanupRule()),
    ], eagerError: true).then((_) => getAuthenticatedAccountAction());
  }

  void _handleLoginNavigateArguments(LoginNavigateArguments arguments) {
    switch (arguments.navigateType) {
      case LoginNavigateType.autoSignIn:
        _handleAutoSignInViaDeepLinkSuccess(arguments.autoSignInViaDeepLinkSuccess!);
        break;
      default:
        _cleanupCache();
        break;
    }
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
  }

  void _continueUsingTheApp(Success authenticationViewStateSuccess) {
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

  void _handleLogOutAndSignInNewAccount({
    required Success authenticationViewStateSuccess,
    required PersonalAccount personalAccount,
    required OpenAppDeepLinkData openAppDeepLinkData,
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
      openAppDeepLinkData: openAppDeepLinkData,
    );
  }

  Future<void> _getSessionActionToLogOut({
    required Success authenticationViewStateSuccess,
    required PersonalAccount personalAccount,
    required OpenAppDeepLinkData openAppDeepLinkData,
  }) async {
    try {
      final sessionViewState = await getSessionInteractor.execute().last;

      sessionViewState.fold(
        (failure) => _handleGetSessionFailureToLogOut(authenticationViewStateSuccess),
        (success) => _handleGetSessionSuccessToLogOut(
          sessionViewStateSuccess: success,
          authenticationViewStateSuccess: authenticationViewStateSuccess,
          personalAccount: personalAccount,
          openAppDeepLinkData: openAppDeepLinkData,
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
    required OpenAppDeepLinkData openAppDeepLinkData,
  }) {
    if (sessionViewStateSuccess is GetSessionSuccess) {
      logoutToSignInNewAccount(
        session: sessionViewStateSuccess.session,
        accountId: personalAccount.accountId!,
        onFailureCallback: ({exception}) {
          if (exception is UserCancelledLogoutOIDCFlowException) {
            _deepLinksManager?.autoSignInViaDeepLink(
              openAppDeepLinkData: openAppDeepLinkData,
              onFailureCallback: () => _continueUsingTheApp(authenticationViewStateSuccess),
              onAutoSignInSuccessCallback: _handleAutoSignInViaDeepLinkSuccess,
            );
          } else {
            _continueUsingTheApp(authenticationViewStateSuccess);
          }
        },
        onSuccessCallback: () => _deepLinksManager?.autoSignInViaDeepLink(
          openAppDeepLinkData: openAppDeepLinkData,
          onFailureCallback: () => _continueUsingTheApp(authenticationViewStateSuccess),
          onAutoSignInSuccessCallback: _handleAutoSignInViaDeepLinkSuccess,
        ),
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

  void _handleAutoSignInViaDeepLinkSuccess(AutoSignInViaDeepLinkSuccess success) {
    setDataToInterceptors(
      baseUrl: success.baseUri.toString(),
      tokenOIDC: success.tokenOIDC,
      oidcConfiguration: success.oidcConfiguration,
    );
    getSessionAction();
  }

  bool _validateToHandleDeepLinksNotSignedIn(Failure failure) {
    return PlatformInfo.isMobile &&
        isNotSignedIn(failure) &&
        _deepLinksManager != null;
  }

  bool _validateToHandleDeepLinksSignedIn(Success success) {
    final personalAccount = _getPersonalAccountFromViewStateSuccess(success);

    return PlatformInfo.isMobile &&
        (success is GetCredentialViewState ||
            success is GetStoredTokenOidcSuccess) &&
        personalAccount != null &&
        _deepLinksManager != null;
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (_validateToHandleDeepLinksNotSignedIn(failure)) {
      _deepLinksManager!.handleDeepLinksWhenAppTerminated(
        onSuccessCallback: (deepLinkData) {
          if (deepLinkData is OpenAppDeepLinkData) {
            _deepLinksManager!.handleOpenAppDeepLinks(
              openAppDeepLinkData: deepLinkData,
              isSignedIn: false,
              onFailureCallback: goToLogin,
              onAutoSignInSuccessCallback: _handleAutoSignInViaDeepLinkSuccess
            );
          } else {
            goToLogin();
          }
        },
        onFailureCallback: goToLogin,
      );
    } else if (isNotSignInOnWeb(failure)) {
      checkOIDCIsAvailable();
    } else if (failure is CheckOIDCIsAvailableFailure) {
      handleCheckOIDCIsAvailableFailure();
    } else if (isGetTokenOIDCFailure(failure)) {
      goToLogin();
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    if (_validateToHandleDeepLinksSignedIn(success)) {
      final personalAccount = _getPersonalAccountFromViewStateSuccess(success);

      _deepLinksManager!.handleDeepLinksWhenAppTerminated(
        onSuccessCallback: (deepLinkData) {
          if (deepLinkData is OpenAppDeepLinkData) {
            _deepLinksManager!.handleOpenAppDeepLinks(
              openAppDeepLinkData: deepLinkData,
              isSignedIn: true,
              username: personalAccount?.userName,
              onConfirmLogoutCallback: (openAppDeepLinkData) => _handleLogOutAndSignInNewAccount(
                authenticationViewStateSuccess: success,
                personalAccount: personalAccount!,
                openAppDeepLinkData: openAppDeepLinkData,
              ),
              onFailureCallback: () => _continueUsingTheApp(success),
            );
          } else {
            _continueUsingTheApp(success);
          }
        },
        onFailureCallback: () => _continueUsingTheApp(success),
      );
    } else if (success is CheckOIDCIsAvailableSuccess) {
      getOIDCConfiguration(success.oidcResponse);
    } else if (success is GetOIDCConfigurationSuccess) {
      handleOIDCConfigurationSuccess(success.oidcConfiguration);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleUrgentExceptionOnWeb({Failure? failure, Exception? exception}) {
    if (failure is CheckOIDCIsAvailableFailure) {
      handleCheckOIDCIsAvailableFailure();
    } else if (isGetTokenOIDCFailure(failure)) {
      goToLogin();
    } else {
      super.handleUrgentExceptionOnWeb(failure: failure, exception: exception);
    }
  }

  @override
  void handleErrorViewState(Object error, StackTrace stackTrace) {
    if (PlatformInfo.isWeb) {
      goToLogin();
    }
  }
}