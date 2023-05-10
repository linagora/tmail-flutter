
import 'package:jmap_dart_client/jmap/core/extensions/date_time_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';

extension ListDetailedEmailHiveCacheExtension on List<DetailedEmailHiveCache> {

  void sortByLatestTime() {
    sort((detailedEmail1, detailedEmail2) {
      return detailedEmail1.timeSaved.compareToSort(detailedEmail2.timeSaved, false);
    });
  }
}