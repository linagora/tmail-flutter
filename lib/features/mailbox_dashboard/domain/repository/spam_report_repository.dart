import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';

abstract class SpamReportRepository {
  Future<void> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported);

  Future<DateTime> getLastTimeDismissedSpamReported();

  Future<void> deleteLastTimeDismissedSpamReported();

  Future<UnreadSpamEmailsResponse> getUnreadSpamMailbox(
    Session session,
    AccountId accountId,
    {
      MailboxFilterCondition? mailboxFilterCondition,
      UnsignedInt? limit
    }
  );

  Future<SpamReportState> getSpamReportState();

  Future<void> storeSpamReportState(SpamReportState spamReportState);

  Future<void> deleteSpamReportState();

  Future<Mailbox> getSpamMailboxCached(AccountId accountId);
}