import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/local_spam_report_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LocalSpamReportDataSourceImpl extends SpamReportDataSource {
  final LocalSpamReportManager _localSpamReportManager;
  final ExceptionThrower _exceptionThrower;

  LocalSpamReportDataSourceImpl(this._localSpamReportManager, this._exceptionThrower);

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
    return Future.sync(() async {
      return await _localSpamReportManager.getLastTimeDismissedSpamReported();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
    return Future.sync(() async {
      return await _localSpamReportManager.storeLastTimeDismissedSpamReported(lastTimeDismissedSpamReported);
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<bool> deleteLastTimeDismissedSpamReported() {
    return Future.sync(() async {
      return await _localSpamReportManager.deleteLastTimeDismissedSpamReported();
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
      return await _localSpamReportManager.deleteLastTimeDismissedSpamReported();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<SpamReportState> getSpamReportState() {
    return Future.sync(() async {
      return await _localSpamReportManager.getSpamReportState();
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeSpamReportState(SpamReportState spamReportState) {
    return Future.sync(() async {
      return await _localSpamReportManager.storeSpamReportState(spamReportState);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Mailbox> getSpamMailboxCached(AccountId accountId, UserName userName) {
    throw UnimplementedError();
  }
}
