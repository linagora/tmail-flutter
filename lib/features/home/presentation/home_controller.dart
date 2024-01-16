import 'dart:async';

import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/email/email_content.dart';
import 'package:model/email/email_content_type.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
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
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_arguments.dart';
import 'package:tmail_ui_user/features/login/presentation/model/login_navigate_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/preview_email_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/restore_active_account_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/select_active_account_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/switch_active_account_arguments.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeController extends ReloadableController {
  final CleanupEmailCacheInteractor _cleanupEmailCacheInteractor;
  final EmailReceiveManager _emailReceiveManager;
  final CleanupRecentSearchCacheInteractor _cleanupRecentSearchCacheInteractor;
  final CleanupRecentLoginUrlCacheInteractor _cleanupRecentLoginUrlCacheInteractor;
  final CleanupRecentLoginUsernameCacheInteractor _cleanupRecentLoginUsernameCacheInteractor;

  HomeController(
    this._cleanupEmailCacheInteractor,
    this._emailReceiveManager,
    this._cleanupRecentSearchCacheInteractor,
    this._cleanupRecentLoginUrlCacheInteractor,
    this._cleanupRecentLoginUsernameCacheInteractor,
  );

  EmailId? _emailIdPreview;
  StreamSubscription? _sessionStreamSubscription;

  @override
  void onInit() {
    if (PlatformInfo.isMobile) {
      ThemeUtils.setSystemDarkUIStyle();
      ThemeUtils.setPreferredFullOrientations();
      _initFlutterDownloader();
      _registerReceivingSharingIntent();
    }
    if (PlatformInfo.isIOS) {
      _handleIOSDataMessage();
    }
    super.onInit();
  }

  @override
  void onReady() {
    _handleNavigateToScreen();
    super.onReady();
  }

  @override
  void onClose() {
    _sessionStreamSubscription?.cancel();
    super.onClose();
  }

  @override
  void handleReloaded(Session session) {
    if (_emailIdPreview != null) {
      popAndPush(
        RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
        arguments: PreviewEmailArguments(
          session: session,
          emailId: _emailIdPreview!
        )
      );
    } else {
      popAndPush(
        RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
        arguments: session
      );
    }
  }

  void _initFlutterDownloader() {
    if (!FlutterDownloader.initialized) {
      FlutterDownloader
        .initialize(debug: kDebugMode)
        .then((_) => FlutterDownloader.registerCallback(downloadCallback));
    }
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {}

  void _handleNavigateToScreen() async {
    if (PlatformInfo.isMobile) {
      if (Get.arguments is LoginNavigateArguments) {
        _handleLoginNavigateArguments(Get.arguments);
      } else {
        final firstTimeAppLaunch = await appStore.getItemBoolean(AppConfig.firstTimeAppLaunchKey);
        if (firstTimeAppLaunch) {
          await _cleanupCache();
        } else {
          _navigateToTwakeWelcomePage();
        }
      }
    } else {
      await _cleanupCache();
    }
  }

  void _navigateToTwakeWelcomePage() {
    popAndPush(AppRoutes.twakeWelcome);
  }

  Future<void> _cleanupCache() async {
    await HiveCacheConfig().onUpgradeDatabase(cachingManager);

    await Future.wait([
      _cleanupEmailCacheInteractor.execute(EmailCleanupRule(Duration.defaultCacheInternal)),
      _cleanupRecentSearchCacheInteractor.execute(RecentSearchCleanupRule()),
      _cleanupRecentLoginUrlCacheInteractor.execute(RecentLoginUrlCleanupRule()),
      _cleanupRecentLoginUsernameCacheInteractor.execute(RecentLoginUsernameCleanupRule()),
    ]).then((value) => getAuthenticatedAccountAction());
  }

  void _registerReceivingSharingIntent() {
    _emailReceiveManager.receivingSharingStream.listen((uri) {
      if (uri != null) {
        if (GetUtils.isEmail(uri.path)) {
          _emailReceiveManager.setPendingEmailAddress(EmailAddress(null, uri.path));
        } else if (uri.scheme == "file") {
          _emailReceiveManager.setPendingFileInfo([SharedMediaFile(uri.path, null, null, SharedMediaType.FILE)]);
        } else {
          _emailReceiveManager.setPendingEmailContent(EmailContent(EmailContentType.textPlain, Uri.decodeComponent(uri.path)));
        }
      }
    });

    _emailReceiveManager.receivingFileSharingStream.listen(_emailReceiveManager.setPendingFileInfo);
  }

  Future _handleIOSDataMessage() async {
    if (Get.arguments is EmailId) {
      _emailIdPreview = Get.arguments;
    } else {
      final notificationInfo = await FcmReceiver.instance.getIOSInitialNotificationInfo();
      if (notificationInfo != null && notificationInfo.containsKey('email_id')) {
        final emailId = notificationInfo['email_id'] as String?;
        if (emailId?.isNotEmpty == true) {
          _emailIdPreview = EmailId(Id(emailId!));
        }
      }
    }
  }

  void _handleLoginNavigateArguments(LoginNavigateArguments navigateArguments) async {
    switch (navigateArguments.navigateType) {
      case LoginNavigateType.switchActiveAccount:
        _switchActiveAccount(
          navigateArguments.currentAccount!,
          navigateArguments.sessionCurrentAccount!,
          navigateArguments.nextActiveAccount!);
        break;
      case LoginNavigateType.selectActiveAccount:
        _showListAccountPicker();
        break;
      default:
        await _cleanupCache();
        break;
    }
  }

  void _switchActiveAccount(
    PersonalAccount currentAccount,
    Session sessionCurrentAccount,
    PersonalAccount nextAccount
  ) {
    setUpInterceptors(nextAccount);

    _sessionStreamSubscription = getSessionInteractor.execute(
      accountId: nextAccount.accountId,
      userName: nextAccount.userName
    ).listen(
      (viewState) {
        viewState.fold(
          (failure) => _handleGetSessionFailureWhenSwitchActiveAccount(
            currentActiveAccount: currentAccount,
            session: sessionCurrentAccount,
            exception: failure),
          (success) => success is GetSessionSuccess
            ? _handleGetSessionSuccessWhenSwitchActiveAccount(
                currentAccount,
                nextAccount,
                sessionCurrentAccount,
                success.session)
            : null,
        );
      },
      onError: (error, stack) {
        logError('HomeController::_switchActiveAccount:Exception: $error | Stack: $stack');
        _handleGetSessionFailureWhenSwitchActiveAccount(
          currentActiveAccount: currentAccount,
          session: sessionCurrentAccount,
          exception: error);
      }
    );
  }

  void _handleGetSessionSuccessWhenSwitchActiveAccount(
    PersonalAccount currentAccount,
    PersonalAccount nextAccount,
    Session sessionCurrentAccount,
    Session sessionNextAccount,
  ) async {
    log('HomeController::_handleGetSessionSuccessWhenSwitchActiveAccount:sessionNextAccount: $sessionNextAccount');
    await popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: SwitchActiveAccountArguments(
        sessionCurrentAccount: sessionCurrentAccount,
        sessionNextAccount: sessionNextAccount,
        currentAccount: currentAccount,
        nextAccount: nextAccount,
      )
    );
  }

  void _restoreActiveAccount({
    required PersonalAccount currentActiveAccount,
    required Session session,
    dynamic exception
  }) async {
    logError('HomeController::_restoreActiveAccount:currentActiveAccount: $currentActiveAccount');
    await popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: RestoreActiveAccountArguments(
        currentAccount: currentActiveAccount,
        session: session,
        exception: exception
      )
    );
  }

  void _handleGetSessionFailureWhenSwitchActiveAccount({
    required PersonalAccount currentActiveAccount,
    required Session session,
    dynamic exception
  }) async {
    logError('HomeController::_handleGetSessionFailureWhenSwitchActiveAccount:exception: $exception');
    _restoreActiveAccount(
      currentActiveAccount: currentActiveAccount,
      session: session,
      exception: exception
    );
  }

  void _showListAccountPicker() {
    if (currentContext == null) {
      logError('HomeController::_showListAccountPicker: context is null');
      return;
    }

    authenticatedAccountManager.showAccountsBottomSheetModal(
      context: currentContext!,
      onSelectActiveAccountAction: _handleSelectActiveAccount,
      onAddAnotherAccountAction: (_) => _handleAddOtherAccount()
    );
  }

  void _handleSelectActiveAccount(PersonalAccount activeAccount) {
    setUpInterceptors(activeAccount);

    _sessionStreamSubscription = getSessionInteractor.execute(
      accountId: activeAccount.accountId,
      userName: activeAccount.userName
    ).listen(
      (viewState) {
        viewState.fold(
          (failure) => _handleGetSessionFailureWhenSelectActiveAccount(
            activeAccount: activeAccount,
            exception: failure),
          (success) => success is GetSessionSuccess
            ? _handleGetSessionSuccessWhenSelectActiveAccount(activeAccount, success.session)
            : null,
        );
      },
      onError: (error, stack) {
        _handleGetSessionFailureWhenSelectActiveAccount(
          activeAccount: activeAccount,
          exception: error);
      }
    );
  }

  void _handleGetSessionSuccessWhenSelectActiveAccount(
    PersonalAccount activeAccount,
    Session sessionActiveAccount
  ) async {
    log('HomeController::_handleGetSessionSuccessWhenSelectActiveAccount:sessionActiveAccount: $sessionActiveAccount');
    await popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: SelectActiveAccountArguments(
        session: sessionActiveAccount,
        activeAccount: activeAccount,
      )
    );
  }

  void _handleGetSessionFailureWhenSelectActiveAccount({
    required PersonalAccount activeAccount,
    dynamic exception
  }) async {
    logError('HomeController::_handleGetSessionFailureWhenSelectActiveAccount:exception: $exception');
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).unableToLogInToAccount(activeAccount.userName?.value ?? ''));
    }

    _showListAccountPicker();
  }

  void _handleAddOtherAccount() {
    navigateToTwakeIdPage();
  }
}