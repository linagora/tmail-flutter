import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/service/search_dispatch_context.dart';

/// Single builder of the executor [SearchDispatchContext] from the dashboard
/// session, shared by every dispatch path (user-triggered controllers and the
/// websocket-triggered refresh provider) so the field-gathering lives in one
/// place. Returns null when no session/account is available yet, so callers
/// never force-unwrap.
extension SearchDispatchContextDashboardExtension on MailboxDashBoardController {
  SearchDispatchContext? buildSearchDispatchContext({
    required bool collapseThreads,
  }) {
    final session = sessionCurrent;
    final currentAccountId = accountId.value;
    if (session == null || currentAccountId == null) return null;

    return SearchDispatchContext(
      session: session,
      accountId: currentAccountId,
      properties:
          EmailUtils.getPropertiesForEmailGetMethod(session, currentAccountId),
      collapseThreads: collapseThreads,
      trashSpamMailboxIds: trashSpamMailboxIds,
    );
  }
}
