
import 'package:jmap_dart_client/jmap/core/extensions/date_time_extension.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';

extension ListRecentLoginUrlExtension on List<RecentLoginUrl> {

  void sortByCreationDate() {
    sort((recentUrl1, recentUrl2) {
      return recentUrl1.creationDate.compareToSort(recentUrl2.creationDate, false);
    });
  }
}