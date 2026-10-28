import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/account_switch_view.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_input_block_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_reload_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/shown_account_load_tracker_provider.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/shown_account_load_tracker.dart';
import 'package:tmail_ui_user/features/delegation/presentation/view/shown_mailbox_selection.dart';

/// Built by an entry point with the container and the navigator above it, so it owns no provider.
class DashboardAccountSwitchView implements AccountSwitchView {
  final ProviderContainer _container;
  final ShownMailboxSelection _selection;
  final GlobalKey<NavigatorState> _navigatorKey;

  const DashboardAccountSwitchView(this._container, this._selection, this._navigatorKey);

  ShownAccountLoadTracker get _loads => _container.read(shownAccountLoadTrackerProvider);

  @override
  bool get hasOpenComposer => _selection.hasOpenComposer;

  /// A dialog, sheet or menu sits above the blocked dashboard and still acts on the old account.
  @override
  void blockInput() {
    _navigatorKey.currentState?.popUntil(_isNotPopup);
    _container.read(shownAccountInputBlockProvider.notifier).block();
  }

  @override
  void unblockInput() => _container.read(shownAccountInputBlockProvider.notifier).unblock();

  @override
  void clearSelectionAndSearch() => _selection.clearSelectionAndSearch();

  @override
  Future<void> loadAccount(ActiveAccount account, int switchAttemptId) {
    if (!_loads.hasFoldersLoad(switchAttemptId)) _requestReload(switchAttemptId);
    return _loads.waitFor(switchAttemptId);
  }

  /// Clears what the target already opened, and reloads an account that stays shown, which no change does.
  @override
  void catchUpAccount(ActiveAccount account, int switchAttemptId) {
    _selection.clearSelectionAndSearch();
    if (!_loads.hasFoldersLoad(switchAttemptId)) _requestReload(switchAttemptId);
  }

  static bool _isNotPopup(Route<dynamic> route) => route is! PopupRoute;

  void _requestReload(int switchAttemptId) {
    _container.read(shownAccountReloadProvider.notifier).request(switchAttemptId);
  }
}
