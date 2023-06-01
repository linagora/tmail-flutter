
import 'package:jmap_dart_client/jmap/core/extensions/date_time_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/sending_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_email_hive_cache.dart';

extension ListSendingEmailHiveCacheExtension on List<SendingEmailHiveCache> {

  List<SendingEmail> toSendingEmails() =>
    map((sendingEmailCache) => sendingEmailCache.toSendingEmail()).toList();

  void sortByLatestTime() {
    sort((detailedEmail1, detailedEmail2) {
      return detailedEmail1.createTime.compareToSort(detailedEmail2.createTime, false);
    });
  }
}