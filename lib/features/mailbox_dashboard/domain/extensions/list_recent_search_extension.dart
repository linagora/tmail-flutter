
import 'package:jmap_dart_client/jmap/core/extensions/date_time_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

extension ListRecentSearchExtension on List<RecentSearch> {

  void sortByCreationDate() {
    sort((recentSearch1, recentSearch2) {
      return recentSearch1.creationDate.compareToSort(
        recentSearch2.creationDate,
        false,
      );
    });
  }
}