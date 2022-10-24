
import 'package:jmap_dart_client/jmap/core/extensions/date_time_extension.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

extension ListRecentLoginUsernameExtension on List<RecentLoginUsername> {

  void sortByCreationDate() {
    sort((recentUsername1, recentUsername2) {
      return recentUsername1.creationDate.compareToSort(recentUsername2.creationDate, false);
    });
  }
}