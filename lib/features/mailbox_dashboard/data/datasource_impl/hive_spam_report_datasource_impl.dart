
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveSpamReportDataSourceImpl extends SpamReportDataSource {
  final MailboxCacheManager _mailboxCacheManager;
  final ExceptionThrower _exceptionThrower;

  HiveSpamReportDataSourceImpl(this._mailboxCacheManager, this._exceptionThrower);

  @override
  Future<bool> deleteLastTimeDismissedSpamReported() {
    throw UnimplementedError();
  }

  @override
  Future<UnreadSpamEmailsResponse> findNumberOfUnreadSpamEmails(Session session, AccountId accountId, {MailboxFilterCondition? mailboxFilterCondition, UnsignedInt? limit}) {
    throw UnimplementedError();
  }

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() {
    throw UnimplementedError();
  }

  @override
  Future<Mailbox> getSpamMailboxCached(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      return await _mailboxCacheManager.getSpamMailbox(accountId, userName);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  @override
  Future<SpamReportState> getSpamReportState() {
    throw UnimplementedError();
  }

  @override
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) {
    throw UnimplementedError();
  }

  @override
  Future<void> storeSpamReportState(SpamReportState spamReportState) {
    throw UnimplementedError();
  }
}