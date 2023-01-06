import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/local/spam_report_cache_manager.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LocalSpamReportDataSourceImpl extends SpamReportDataSource {
  final SpamReportCacheManager _spamReportCacheManager;
  final ExceptionThrower _exceptionThrower;

  LocalSpamReportDataSourceImpl(this._spamReportCacheManager, this._exceptionThrower);
  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
    return Future.sync(() async {
      return await _spamReportCacheManager.getlastTimeDismissedSpamReported();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<bool> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) async {
    return Future.sync(() async {
      return await _spamReportCacheManager.storelastTimeDismissedSpamReported(lastTimeDismissedSpamReported);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
  
  @override
  Future<bool> deleteLastTimeDismissedSpamReported() {
    return Future.sync(() async {
      return await _spamReportCacheManager.deleteLastTimeDismissedSpamReported();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}
