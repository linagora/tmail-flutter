
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

part 'recent_search_cache.g.dart';

@HiveType(typeId: CachingConstants.RECENT_SEARCH_HIVE_CACHE_IDENTIFY)
class RecentSearchCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String value;

  @HiveField(1)
  final DateTime creationTime;

  RecentSearchCache(this.value, this.creationTime);

  @override
  List<Object?> get props => [value, creationTime];
}

extension RecentSearchExtension on RecentSearch {
  RecentSearchCache toRecentSearchCache() {
    return RecentSearchCache(value, creationDate);
  }
}