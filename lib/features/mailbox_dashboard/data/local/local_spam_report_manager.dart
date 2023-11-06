import 'package:core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';

class LocalSpamReportManager {
  static const String _keyLastTimeDismissedSpamReported = 'KEY_LAST_TIME_DISMISSED_SPAM_REPORTED';
  static const String _keySpamReportState = 'KEY_SPAM_REPORT_STATE';

  final SharedPreferences _sharedPreferences;

  LocalSpamReportManager(this._sharedPreferences);

  Future<DateTime> getLastTimeDismissedSpamReported() async {
    final timeStamp = _sharedPreferences.getInt(_keyLastTimeDismissedSpamReported) ?? 0;
    log('LocalSpamReportManager::getLastTimeDismissedSpamReported:timeStamp: $timeStamp');
    final lastTimeDismissedSpamReported =  DateTime.fromMillisecondsSinceEpoch(timeStamp);
    return lastTimeDismissedSpamReported;
  }
  
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
    final timeStamp = lastTimeDismissedSpamReported.millisecondsSinceEpoch;
    log('LocalSpamReportManager::storeLastTimeDismissedSpamReported:timeStamp: $timeStamp');
    return await _sharedPreferences.setInt(_keyLastTimeDismissedSpamReported, timeStamp);
  }

  Future<bool> deleteLastTimeDismissedSpamReported() async {
    return await _sharedPreferences.remove(_keyLastTimeDismissedSpamReported);
  }

  Future<bool> deleteSpamReportState() async {
    return await _sharedPreferences.remove(_keySpamReportState);
  }

  Future<SpamReportState> getSpamReportState() async {
    final spamReportState = _sharedPreferences.getString(_keySpamReportState) ?? '';
    return spamReportState == SpamReportState.disabled.keyValue ? SpamReportState.disabled : SpamReportState.enabled;
  }

  Future<bool> storeSpamReportState(SpamReportState spamReportState) async {
    final spamReportState0 = spamReportState.keyValue;
    return await _sharedPreferences.setString(_keySpamReportState, spamReportState0);
  }

  Future<void> clear() async {
    await deleteLastTimeDismissedSpamReported();
    await deleteSpamReportState();
  }
}