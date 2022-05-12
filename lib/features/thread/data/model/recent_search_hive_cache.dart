
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'recent_search_hive_cache.g.dart';

@HiveType(typeId: CachingConstants.RECENT_SEARCH_HIVE_CACHE_IDENTIFY)
class RecentSearchHiveCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String? value;

  @HiveField(1)
  final DateTime? searchedAt;

  RecentSearchHiveCache(
    {
      this.value,
      this.searchedAt,
    }
  );

  @override
  List<Object?> get props => [
    value,
    searchedAt,
  ];
}