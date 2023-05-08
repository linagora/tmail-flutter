import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/share_preference_spam_report_data_source.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class SharePreferenceSpamReportDataSourceImpl extends SpamReportDataSource {
  final SharePreferenceSpamReportDataSource _sharePreferenceSpamReportDataSource;
  final ExceptionThrower _exceptionThrower;

  SharePreferenceSpamReportDataSourceImpl(this._sharePreferenceSpamReportDataSource, this._exceptionThrower);

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.getLastTimeDismissedSpamReported();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.storeLastTimeDismissedSpamReported(lastTimeDismissedSpamReported);
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<bool> deleteLastTimeDismissedSpamReported() {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.deleteLastTimeDismissedSpamReported();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<UnreadSpamEmailsResponse> findNumberOfUnreadSpamEmails(
    Session session,
    AccountId accountId,
    {
      MailboxFilterCondition? mailboxFilterCondition,
      UnsignedInt? limit
    }
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSpamReportState() {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.deleteLastTimeDismissedSpamReported();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<SpamReportState> getSpamReportState() {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.getSpamReportState();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeSpamReportState(SpamReportState spamReportState) {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.storeSpamReportState(spamReportState);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Mailbox> getSpamMailboxCached(AccountId accountId) {
    throw UnimplementedError();
  }
}
