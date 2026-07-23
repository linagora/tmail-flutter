import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

/// Provides applied server email-state changes to search refresh consumers.
abstract class EmailStateChangeSource {
  /// Emits server email-state changes.
  Stream<jmap.State> get onEmailStateChanged;

  /// The email state the app is already synced to, or null before the first
  /// sync. Lets a refresh skip a change it has already applied.
  jmap.State? get currentAppliedState;
}

/// Adapts the dashboard email action stream to [EmailStateChangeSource].
class DashboardEmailStateChangeSource implements EmailStateChangeSource {
  DashboardEmailStateChangeSource(this._dashboard);

  final MailboxDashBoardController _dashboard;

  @override
  /// Emits refresh-change actions from the dashboard stream.
  Stream<jmap.State> get onEmailStateChanged => _dashboard.emailUIAction.stream
      .where((action) => action is RefreshChangeEmailAction)
      .map((action) => (action as RefreshChangeEmailAction).newState);

  @override
  jmap.State? get currentAppliedState => _dashboard.currentEmailState;

  // Same dashboard ⇒ equal source, so a provider recompute keeps the identical
  // value and does not rebuild the refresh coordinator — preserving its
  // websocket queue and dedup memory. Only a real dashboard swap (re-login)
  // yields a new source and a fresh coordinator.
  @override
  bool operator ==(Object other) =>
      other is DashboardEmailStateChangeSource &&
      identical(other._dashboard, _dashboard);

  @override
  int get hashCode => identityHashCode(_dashboard);
}
