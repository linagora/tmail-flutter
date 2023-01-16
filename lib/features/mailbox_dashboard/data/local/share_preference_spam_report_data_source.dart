import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/utils/mailbox_dashboard_constant.dart';

class SharePreferenceSpamReportDataSource extends SpamReportDataSource {
  final SharedPreferences _sharedPreferences;

  SharePreferenceSpamReportDataSource(this._sharedPreferences);

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
    final _timeStamp = _sharedPreferences.getInt(MailboxDashboardConstant.keyLastTimeDismissedSpamReported) ?? 0;
    final _lastTimeDismissedSpamReported =  DateTime.fromMillisecondsSinceEpoch(_timeStamp);
    return _lastTimeDismissedSpamReported;
  }
  
  @override
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
    final _timeStamp = lastTimeDismissedSpamReported.millisecondsSinceEpoch;
    return await _sharedPreferences.setInt(MailboxDashboardConstant.keyLastTimeDismissedSpamReported,_timeStamp);
  }

  @override
  Future<bool> deleteLastTimeDismissedSpamReported() async {
    return await _sharedPreferences.remove(MailboxDashboardConstant.keyLastTimeDismissedSpamReported);
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

  @override
  Future<bool> deleteSpamReportState() async {
    return await _sharedPreferences.remove(MailboxDashboardConstant.keySpamReportState);
  }

  @override
  Future<SpamReportState> getSpamReportState() async {
    final _spamReportState = _sharedPreferences.getString(MailboxDashboardConstant.keySpamReportState) ?? '';
    return _spamReportState == SpamReportState.disabled.keyValue ? SpamReportState.disabled : SpamReportState.enabled;
  }

  @override
  Future<bool> storeSpamReportState(SpamReportState spamReportState) async {
    final _spamReportState = spamReportState.keyValue;
    return await _sharedPreferences.setString(MailboxDashboardConstant.keySpamReportState, _spamReportState);
  }
}