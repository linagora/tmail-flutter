import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
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
import 'package:tmail_ui_user/features/home/domain/state/get_session_cache_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/data/extensions/personal_account_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/preview_email_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/reopen_app_arguments.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/services/fcm_receiver.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class HomeController extends ReloadableController {
  final CleanupEmailCacheInteractor _cleanupEmailCacheInteractor;
  final EmailReceiveManager _emailReceiveManager;
  final CleanupRecentSearchCacheInteractor _cleanupRecentSearchCacheInteractor;
  final CleanupRecentLoginUrlCacheInteractor _cleanupRecentLoginUrlCacheInteractor;
  final CleanupRecentLoginUsernameCacheInteractor _cleanupRecentLoginUsernameCacheInteractor;
  final GetSessionCacheInteractor _getSessionCacheInteractor;

  HomeController(
    this._cleanupEmailCacheInteractor,
    this._emailReceiveManager,
    this._cleanupRecentSearchCacheInteractor,
    this._cleanupRecentLoginUrlCacheInteractor,
    this._cleanupRecentLoginUsernameCacheInteractor,
    this._getSessionCacheInteractor,
  );

  PersonalAccount? currentAccount;
  EmailId? _emailIdPreview;

  @override
  void onInit() {
    if (PlatformInfo.isMobile) {
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
    _cleanupCache();
    super.onReady();
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
    FlutterDownloader
      .initialize(debug: kDebugMode)
      .then((_) => FlutterDownloader.registerCallback(downloadCallback));
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {}

  Future<void> _cleanupCache() async {
    log('HomeController::_cleanupCache:');
    await HiveCacheConfig.instance.onUpgradeDatabase(cachingManager);

    await Future.wait([
      _cleanupEmailCacheInteractor.execute(EmailCleanupRule(Duration.defaultCacheInternal)),
      _cleanupRecentSearchCacheInteractor.execute(RecentSearchCleanupRule()),
      _cleanupRecentLoginUrlCacheInteractor.execute(RecentLoginUrlCleanupRule()),
      _cleanupRecentLoginUsernameCacheInteractor.execute(RecentLoginUsernameCleanupRule()),
    ]).then((_) => getAuthenticatedAccountAction());
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

  void _goToMailboxDashboardWithSession({
    required PersonalAccount personalAccount,
    required Session session
  }) {
    log('HomeController::_goToMailboxDashboardWithSession:');
    popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: ReopenAppArguments(
        personalAccount: personalAccount,
        session: session));
  }

  void _goToMailboxDashboardWithoutSession({required PersonalAccount personalAccount}) {
    log('HomeController::_goToMailboxDashboardWithoutSession:');
    popAndPush(
      RouteUtils.generateNavigationRoute(AppRoutes.dashboard),
      arguments: ReopenAppArguments(personalAccount: personalAccount));
  }

  @override
  void getSessionAction({PersonalAccount? personalAccount}) {
    log('HomeController::getSessionAction:');
    if (PlatformInfo.isMobile && personalAccount?.existAccountIdAndUserName == true) {
      consumeState(_getSessionCacheInteractor.execute(personalAccount!));
    } else {
      super.getSessionAction();
    }
  }

  @override
  void handleSuccessViewState(Success success) {
    log('HomeController::handleSuccessViewState: ${success.runtimeType}');
    if (success is GetSessionCacheSuccess) {
      _goToMailboxDashboardWithSession(
        personalAccount: success.personalAccount,
        session: success.session);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    log('HomeController::handleFailureViewState: ${failure.runtimeType}');
    if (failure is GetSessionCacheFailure) {
      _goToMailboxDashboardWithoutSession(personalAccount: failure.personalAccount);
    } else {
      super.handleFailureViewState(failure);
    }
  }
}