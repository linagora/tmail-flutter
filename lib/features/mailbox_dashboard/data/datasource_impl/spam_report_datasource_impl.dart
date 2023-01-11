
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/spam_report_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class SpamReportDataSourceImpl extends SpamReportDataSource {
  final SpamReportApi _spamReportApi;
  final ExceptionThrower _exceptionThrower;

  SpamReportDataSourceImpl(this._spamReportApi, this._exceptionThrower);

  @override
  Future<bool> deleteLastTimeDismissedSpamReported() {
    throw UnimplementedError();
  }

  @override
  Future<UnreadSpamEmailsResponse> findNumberOfUnreadSpamEmails(
    AccountId accountId,
    {
      MailboxFilterCondition? mailboxFilterCondition,
      UnsignedInt? limit
    }
  ) {
     return Future.sync(() async {
      final _unreadSpamEmailsResponse = await _spamReportApi.findNumberOfUnreadSpamEmails(
        accountId, mailboxFilterCondition: mailboxFilterCondition, limit: limit);
      return _unreadSpamEmailsResponse;
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() {
    throw UnimplementedError();
  }

  @override
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) {
    throw UnimplementedError();
  }

}