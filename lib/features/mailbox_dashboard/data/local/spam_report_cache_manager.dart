import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/utils/mailbox_dashboard_constant.dart';

class SpamReportCacheManager {
  final SharedPreferences _sharedPreferences;

  SpamReportCacheManager(this._sharedPreferences);

  Future<DateTime> getlastTimeDismissedSpamReported() async {
    final _timeStamp = _sharedPreferences.getInt(MailboxDashboardConstant.keyLastTimeDismissedSpamReported) ?? 0;
    final _lastTimeDismissedSpamReported =  DateTime.fromMillisecondsSinceEpoch(_timeStamp);
    return _lastTimeDismissedSpamReported;
  }

  Future<bool> storelastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
   final _timeStamp = lastTimeDismissedSpamReported.microsecondsSinceEpoch;
   return await _sharedPreferences.setInt(MailboxDashboardConstant.keyLastTimeDismissedSpamReported,_timeStamp);
  }

  Future<bool> deleteLastTimeDismissedSpamReported() async {
   return await _sharedPreferences.remove(MailboxDashboardConstant.keyLastTimeDismissedSpamReported);
  }
}