import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/utils/mailbox_dashboard_constant.dart';

class SharePreferenceSpamReportDataSource extends SpamReportDataSource {
  final SharedPreferences _sharedPreferences;

  SharePreferenceSpamReportDataSource(this._sharedPreferences);

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
    final timeStamp = _sharedPreferences.getInt(MailboxDashboardConstant.keyLastTimeDismissedSpamReported) ?? 0;
    final lastTimeDismissedSpamReported =  DateTime.fromMillisecondsSinceEpoch(timeStamp);
    return lastTimeDismissedSpamReported;
  }
  
  @override
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
    final timeStamp = lastTimeDismissedSpamReported.millisecondsSinceEpoch;
    return await _sharedPreferences.setInt(MailboxDashboardConstant.keyLastTimeDismissedSpamReported,timeStamp);
  }

  @override
  Future<bool> deleteLastTimeDismissedSpamReported() async {
    return await _sharedPreferences.remove(MailboxDashboardConstant.keyLastTimeDismissedSpamReported);
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
  Future<bool> deleteSpamReportState() async {
    return await _sharedPreferences.remove(MailboxDashboardConstant.keySpamReportState);
  }

  @override
  Future<SpamReportState> getSpamReportState() async {
    final spamReportState = _sharedPreferences.getString(MailboxDashboardConstant.keySpamReportState) ?? '';
    return spamReportState == SpamReportState.disabled.keyValue ? SpamReportState.disabled : SpamReportState.enabled;
  }

  @override
  Future<bool> storeSpamReportState(SpamReportState spamReportState) async {
    final spamReportState0 = spamReportState.keyValue;
    return await _sharedPreferences.setString(MailboxDashboardConstant.keySpamReportState, spamReportState0);
  }

  @override
  Future<Mailbox> getSpamMailboxCached(AccountId accountId, UserName userName) {
    throw UnimplementedError();
  }
}