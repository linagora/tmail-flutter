
import 'package:core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/search_view_state_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

extension HandleReactiveObxVariableExtension on MailboxDashBoardController {

  void registerReactiveObxVariableListener() {
    advancedSearchViewSubscription ??= appProviderContainer.listen(
      searchViewStateProvider.select((state) => state.isAdvancedSearchViewOpen),
      (_, visible) => _onAdvancedSearchVisibleChanged(visible),
    );
    searchInputFocusSubscription ??= appProviderContainer.listen(
      searchViewStateProvider.select((state) => state.isSearchInputFocused),
      (_, focused) => onSearchInputFocusChanged(focused),
    );
  }

  void disposeReactiveSearchStateListeners() {
    advancedSearchViewSubscription?.close();
    searchInputFocusSubscription?.close();
    advancedSearchViewSubscription = null;
    searchInputFocusSubscription = null;
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
}
