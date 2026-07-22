import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

/// Provides applied server email-state changes to search refresh consumers.
abstract class EmailStateChangeSource {
  /// Emits server email-state changes.
  Stream<jmap.State> get onEmailStateChanged;
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
}
