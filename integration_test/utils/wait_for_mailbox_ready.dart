import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../extensions/mailbox_dashboard_controller_integration_test_extensions.dart';
import 'test_timeouts.dart';
import 'wait_for_condition.dart';

/// Waits until the mailbox dashboard is fully loaded (session, account id and
/// selected mailbox are available).
///
/// The app reaches this state only after the silent (seeded-credentials) login
/// completes, so anything that touches the dashboard before then — provisioning
/// directly through controllers, or tapping UI that only the thread view renders
/// (e.g. the compose button) — must await this first.
Future<void> waitForMailboxReady({
  Duration timeout = TestTimeouts.long,
}) =>
    waitForCondition(
      () => getBinding<MailboxDashBoardController>().isReady,
      timeout: timeout,
    );
