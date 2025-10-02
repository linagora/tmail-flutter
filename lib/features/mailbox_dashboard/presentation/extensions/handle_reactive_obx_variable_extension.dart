
import 'package:core/utils/app_logger.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';

extension HandleReactiveObxVariableExtension on MailboxDashBoardController {

  void registerReactiveObxVariableListener() {
    advancedSearchVisibleWorker = ever(
      searchController.isAdvancedSearchViewOpen,
      _onAdvancedSearchVisibleChanged
    );

    searchInputFocusWorker = ever(
      searchController.isSearchInputFocused,
      onSearchInputFocusChanged
    );
  }

  void _onAdvancedSearchVisibleChanged(bool visible) {
    log('$runtimeType::_onAdvancedSearchVisibleChanged: visible is $visible | isEmailOpened = $isEmailOpened');
    if (isEmailOpened) {
      _performThreadDetailUIActionWhenEmailOpened(visible);
    } else if (isEmailListDisplayed) {
      _performDashboardUIActionWhenEmailListDisplayed(visible);
    }
  }

  void onSearchInputFocusChanged(bool focused) {
    log('$runtimeType::_onSearchInputFocusChanged: focused is $focused | isEmailOpened = $isEmailOpened');
    if (isEmailOpened) {
      _performThreadDetailUIActionWhenEmailOpened(focused);
    } else if (isEmailListDisplayed) {
      _performDashboardUIActionWhenEmailListDisplayed(focused);
    }
  }

  void _performThreadDetailUIActionWhenEmailOpened(bool focused) {
    final emailAction = focused
        ? ClearMailViewKeyboardShortcutFocusAction()
        : ReclaimMailViewKeyboardShortcutFocusAction();

    dispatchThreadDetailUIAction(emailAction);
  }

  void _performDashboardUIActionWhenEmailListDisplayed(bool focused) {
    final dashboardAction = focused
        ? ClearMailListKeyboardShortcutFocusAction()
        : ReclaimMailListKeyboardShortcutFocusAction();

    dispatchAction(dashboardAction);
  }

  void disposeReactiveObxVariableListener() {
    advancedSearchVisibleWorker?.dispose();
    advancedSearchVisibleWorker = null;
    searchInputFocusWorker?.dispose();
    searchInputFocusWorker = null;
  }
}