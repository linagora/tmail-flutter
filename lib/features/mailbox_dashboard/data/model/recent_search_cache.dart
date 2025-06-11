
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:jmap_dart_client/jmap/core/extensions/date_time_extension.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

part 'recent_search_cache.g.dart';

@HiveType(typeId: CachingConstants.RECENT_SEARCH_HIVE_CACHE_IDENTIFY)
class RecentSearchCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String value;

  @HiveField(1)
  final DateTime creationDate;

  RecentSearchCache(this.value, this.creationDate);

  @override
  List<Object?> get props => [value, creationDate];
}

extension RecentSearchExtension on RecentSearch {
  RecentSearchCache toRecentSearchCache() {
    return RecentSearchCache(value, creationDate);
  }
}

extension RecentSearchCacheExtension on RecentSearchCache {
  RecentSearch toRecentSearch() {
    return RecentSearch(value, creationDate);
  }

  bool match(String pattern) {
    return value.toLowerCase().contains(pattern.toLowerCase());
  }
}

extension ListRecentSearchCacheExtension on List<RecentSearchCache> {

  void sortByCreationDate() {
    sort((recentSearch1, recentSearch2) {
      return recentSearch1.creationDate.compareToSort(
        recentSearch2.creationDate,
        false,
      );
    });
  }
}