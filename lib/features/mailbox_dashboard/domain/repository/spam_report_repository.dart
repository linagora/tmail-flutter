import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';

abstract class SpamReportRepository {
  Future<void> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported);

  Future<DateTime> getLastTimeDismissedSpamReported();

  Future<void> deleteLastTimeDismissedSpamReported();

  Future<SpamReportState> getSpamReportState();

  Future<void> storeSpamReportState(SpamReportState spamReportState);

  Future<void> deleteSpamReportState();

  Future<Mailbox> getSpamMailboxCached(AccountId accountId, UserName userName);
}