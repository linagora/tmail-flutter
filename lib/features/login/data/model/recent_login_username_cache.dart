import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:jmap_dart_client/jmap/core/extensions/date_time_extension.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

part 'recent_login_username_cache.g.dart';

@HiveType(typeId: CachingConstants.RECENT_LOGIN_USERNAME_HIVE_CACHE_IDENTITY)
class RecentLoginUsernameCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String username;

  @HiveField(1)
  final DateTime creationDate;

  RecentLoginUsernameCache(this.username, this.creationDate);

  @override
  List<Object?> get props => [username, creationDate];
}

extension RecentLoginUsernameExtension on RecentLoginUsername {
  RecentLoginUsernameCache toRecentLoginUsernameCache() {
    return RecentLoginUsernameCache(username, creationDate);
  }
}

extension RecentLoginUsernameCacheExtension on RecentLoginUsernameCache {
  RecentLoginUsername toRecentLoginUsername() {
    return RecentLoginUsername(username, creationDate);
  }

  bool matchUsername(String pattern) {
    return username.toLowerCase().contains(pattern);
  }
}

extension ListRecentLoginUsernameCacheExtension on List<RecentLoginUsernameCache> {
  void sortByCreationDate() {
    sort((recentUsername1, recentUsername2) {
      return recentUsername1.creationDate.compareToSort(recentUsername2.creationDate, false);
    });
  }
}