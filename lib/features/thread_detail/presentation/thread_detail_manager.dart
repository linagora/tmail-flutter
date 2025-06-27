import 'package:collection/collection.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_detail_status_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_detail_status_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/refresh_thread_detail_on_setting_changed.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/model/thread_detail_setting_status.dart';

class ThreadDetailManager extends BaseController {
  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final GetThreadDetailStatusInteractor _getThreadDetailStatusInteractor;

  ThreadDetailManager(this._getThreadDetailStatusInteractor);  

  final availableThreadIds = RxList<ThreadId>();
  final currentMobilePageViewIndex = 0.obs;
  PageController? pageController;

  final threadDetailSettingStatus = ThreadDetailSettingStatus.loading.obs;
  AppLifecycleListener? appLifecycleListener;
  bool threadDetailWasEnabled = true;

  bool get isSearchingOnMobile =>
      mailboxDashBoardController.searchController.isSearchEmailRunning &&
      PlatformInfo.isMobile;

  RxList<PresentationEmail> get currentDisplayedEmails => isSearchingOnMobile
      ? mailboxDashBoardController.listResultSearch
      : mailboxDashBoardController.emailsInCurrentMailbox;

  ThreadId? get currentThreadId =>
      mailboxDashBoardController.selectedEmail.value?.threadId;
  EmailId? get currentEmailId =>
      mailboxDashBoardController.selectedEmail.value?.id;

  bool get isThreadDetailEnabled =>
      threadDetailSettingStatus.value == ThreadDetailSettingStatus.enabled;

  @override
  void onInit() {
    super.onInit();
    consumeState(_getThreadDetailStatusInteractor.execute());
    appLifecycleListener = AppLifecycleListener(
      onResume: () {
        if (threadDetailSettingStatus.value == ThreadDetailSettingStatus.loading) {
          return;
        }

        consumeState(_getThreadDetailStatusInteractor.execute());
      },
    );
    ever(mailboxDashBoardController.threadDetailUIAction, (action) {
      if (action is UpdatedThreadDetailSettingAction) {
        consumeState(_getThreadDetailStatusInteractor.execute());
      }
      // Reset [threadDetailUIAction] to original value
      mailboxDashBoardController.dispatchThreadDetailUIAction(
        ThreadDetailUIAction(),
      );
    });
    ever(
      mailboxDashBoardController.dashboardRoute,
      (route) {
        final selectedEmail = mailboxDashBoardController.selectedEmail.value;
        if (route != DashboardRoutes.threadDetailed || selectedEmail == null) {
          currentMobilePageViewIndex.value = -1;
          pageController?.dispose();
          pageController = null;
          availableThreadIds.clear();
          return;
        }

        availableThreadIds.value = currentDisplayedEmails
            .map((presentationEmail) => presentationEmail.threadId)
            .toSet()
            .whereNotNull()
            .toList();

        if (isThreadDetailEnabled && selectedEmail.threadId != null) {
          final currentThreadIndex = availableThreadIds.indexOf(
            selectedEmail.threadId!,
          );
          currentMobilePageViewIndex.value = currentThreadIndex;
        } else {
          if (selectedEmail.id != null) {
            final currentEmailIndex = currentDisplayedEmails.indexOf(
              selectedEmail,
            );
            currentMobilePageViewIndex.value = currentEmailIndex;
          }
        }

        pageController ??= PageController(
          initialPage: currentMobilePageViewIndex.value,
        );
      },
    );
  }

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetThreadDetailStatusSuccess) {
      threadDetailSettingStatus.value = success.threadDetailEnabled
          ? ThreadDetailSettingStatus.enabled
          : ThreadDetailSettingStatus.disabled;
      refreshThreadDetailOnSettingChanged();
    } else if (success is GettingThreadDetailStatus) {
      threadDetailSettingStatus.value = ThreadDetailSettingStatus.loading;
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetThreadDetailStatusFailure) {
      threadDetailSettingStatus.value = ThreadDetailSettingStatus.enabled;
      refreshThreadDetailOnSettingChanged();
      return;
    }
    super.handleFailureViewState(failure);
  }
}
