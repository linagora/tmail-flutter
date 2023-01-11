import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/share_preference_spam_report_data_source.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LocalSpamReportDataSourceImpl extends SpamReportDataSource {
  final SharePreferenceSpamReportDataSource _sharePreferenceSpamReportDataSource;
  final ExceptionThrower _exceptionThrower;

  LocalSpamReportDataSourceImpl(this._sharePreferenceSpamReportDataSource, this._exceptionThrower);
  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.getLastTimeDismissedSpamReported();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.storeLastTimeDismissedSpamReported(lastTimeDismissedSpamReported);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
  
  @override
  Future<bool> deleteLastTimeDismissedSpamReported() {
    return Future.sync(() async {
      return await _sharePreferenceSpamReportDataSource.deleteLastTimeDismissedSpamReported();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<UnreadSpamEmailsResponse> findNumberOfUnreadSpamEmails(
    AccountId accountId,
    {
      MailboxFilterCondition? mailboxFilterCondition,
      UnsignedInt? limit
    }
  ) {
    throw UnimplementedError();
  }
}
