import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';

class SpamReportRepositoryImpl extends SpamReportRepository {
  final Map<DataSourceType, SpamReportDataSource> mapDataSource;

  SpamReportRepositoryImpl(this.mapDataSource);

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
   return await mapDataSource[DataSourceType.local]!.getLastTimeDismissedSpamReported();
  }
  
  @override
  Future<void> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) {
   return mapDataSource[DataSourceType.local]!.storeLastTimeDismissedSpamReported(lastTimeDismissedSpamReported);
  }
  
  @override
  Future<void> deleteLastTimeDismissedSpamReported() {
    return mapDataSource[DataSourceType.local]!.deleteLastTimeDismissedSpamReported();
  }

  @override
  Future<UnreadSpamEmailsResponse> getUnreadSpamMailbox(
    Session session,
    AccountId accountId,
    {
      MailboxFilterCondition? mailboxFilterCondition,
      UnsignedInt? limit
    }
  ) {
    return mapDataSource[DataSourceType.network]!.findNumberOfUnreadSpamEmails(
      session,
      accountId,
      mailboxFilterCondition: mailboxFilterCondition,
      limit: limit);
  }

  @override
  Future<SpamReportState> getSpamReportState() async {
    return await mapDataSource[DataSourceType.local]!.getSpamReportState();
  }

  @override
  Future<void> storeSpamReportState(SpamReportState spamReportState) {
    return mapDataSource[DataSourceType.local]!.storeSpamReportState(spamReportState);
  }
  
  @override
  Future<void> deleteSpamReportState() {
    return mapDataSource[DataSourceType.local]!.deleteSpamReportState();
  }

  @override
  Future<Mailbox> getSpamMailboxCached() {
    return mapDataSource[DataSourceType.cache]!.getSpamMailboxCached();
  }
}