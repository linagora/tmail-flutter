
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

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