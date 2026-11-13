import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/delegation/presentation/view/account_switch_dashboard.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';

/// Uses only the public API of the dashboard, so a switch adds nothing to it.
class GetXAccountSwitchDashboard implements AccountSwitchDashboard {
  final MailboxDashBoardController _dashboard;

  const GetXAccountSwitchDashboard(this._dashboard);

  /// A mobile composer is its own route, whose controller is registered without a tag while it is open.
  @override
  bool get hasOpenComposer => _dashboard.composerManager.hasComposer || Get.isRegistered<ComposerController>();

  /// Like opening a folder, so no filter, search field or opened email of the old account stays.
  @override
  void resetForNewAccount() {
    _dashboard.clearSelectedEmail();
    _dashboard.clearFilterMessageOption();
    _dashboard.dispatchAction(ClearAllFieldOfAdvancedSearchAction());
    _dashboard.searchController.disableAllSearchEmail();
    // The target's first email list then runs /changes instead of trusting its cache.
    _dashboard.setIsFirstSessionLoad(true);
    // A refresh before that list must not send the old account's email state to the target.
    _dashboard.setCurrentEmailState(null);
    _dashboard.setSelectedMailbox(null);
    _dashboard.dispatchRoute(DashboardRoutes.thread);
  }

  @override
  void reloadLabelSettingForShownAccount() => _dashboard.reloadLabelSettingForShownAccount();

  /// Session setup registers the autocomplete bindings and minimum length of my own account only.
  @override
  void setUpAutocompleteForShownAccount() {
    final session = _dashboard.sessionCurrent;
    final accountId = _dashboard.activeAccountId;
    if (session == null || accountId == null) return;
    _dashboard.injectAutoCompleteBindings(session, accountId);
    _dashboard.minInputLengthAutocomplete = _dashboard.getMinInputLengthAutocomplete(
      session: session,
      accountId: accountId,
    );
  }
}
