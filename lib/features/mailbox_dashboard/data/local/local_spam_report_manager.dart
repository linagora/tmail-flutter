import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/utils/mailbox_dashboard_constant.dart';

class LocalSpamReportManager {
  final SharedPreferences _sharedPreferences;

  LocalSpamReportManager(this._sharedPreferences);

  Future<DateTime> getLastTimeDismissedSpamReported() async {
    final timeStamp = _sharedPreferences.getInt(MailboxDashboardConstant.keyLastTimeDismissedSpamReported) ?? 0;
    final lastTimeDismissedSpamReported =  DateTime.fromMillisecondsSinceEpoch(timeStamp);
    return lastTimeDismissedSpamReported;
  }
  
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
    final timeStamp = lastTimeDismissedSpamReported.millisecondsSinceEpoch;
    return await _sharedPreferences.setInt(MailboxDashboardConstant.keyLastTimeDismissedSpamReported,timeStamp);
  }

  Future<bool> deleteLastTimeDismissedSpamReported() async {
    return await _sharedPreferences.remove(MailboxDashboardConstant.keyLastTimeDismissedSpamReported);
  }

  Future<bool> deleteSpamReportState() async {
    return await _sharedPreferences.remove(MailboxDashboardConstant.keySpamReportState);
  }

  Future<SpamReportState> getSpamReportState() async {
    final spamReportState = _sharedPreferences.getString(MailboxDashboardConstant.keySpamReportState) ?? '';
    return spamReportState == SpamReportState.disabled.keyValue ? SpamReportState.disabled : SpamReportState.enabled;
  }

  Future<bool> storeSpamReportState(SpamReportState spamReportState) async {
    final spamReportState0 = spamReportState.keyValue;
    return await _sharedPreferences.setString(MailboxDashboardConstant.keySpamReportState, spamReportState0);
  }

  Future<void> clear() async {
    await deleteLastTimeDismissedSpamReported();
    await deleteSpamReportState();
  }
}