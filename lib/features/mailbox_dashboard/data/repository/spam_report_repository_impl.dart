import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/spam_report_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/spam_report_repository.dart';

class SpamReportRepositoryImpl extends SpamReportRepository {
  final Map<DataSourceType, SpamReportDataSource> mapDataSource;

  SpamReportRepositoryImpl(this.mapDataSource);

  @override
  Future<DateTime> getLastTimeDismissedSpamReported() async {
   return await mapDataSource[DataSourceType.local]!.getLastTimeDismissedSpamReported();
  }
  
  @override
  Future<void> storeLastTimeDismissedSpamReported(DateTime lastTimeDismissedSpamReported) {
   return mapDataSource[DataSourceType.local]!.storeLastTimeDismissedSpamReported(lastTimeDismissedSpamReported);
  }
  
  @override
  Future<void> deleteLastTimeDismissedSpamReported() {
    return mapDataSource[DataSourceType.local]!.deleteLastTimeDismissedSpamReported();
  }
}