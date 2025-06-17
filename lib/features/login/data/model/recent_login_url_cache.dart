import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:jmap_dart_client/jmap/core/extensions/date_time_extension.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';

part 'recent_login_url_cache.g.dart';

@HiveType(typeId: CachingConstants.RECENT_LOGIN_URL_HIVE_CACHE_IDENTITY)
class RecentLoginUrlCache extends HiveObject with EquatableMixin {
  
  @HiveField(0)
  final String url;

  @HiveField(1)
  final DateTime creationDate;

  RecentLoginUrlCache(this.url, this.creationDate);

  @override
  List<Object?> get props => [url, creationDate];
}

extension RecentLoginUrlExtension on RecentLoginUrl {
  RecentLoginUrlCache toRecentLoginUrlCache() {
    return RecentLoginUrlCache(url, creationDate);
  }
}

extension RecentLoginUrlCacheExtension on RecentLoginUrlCache {
  RecentLoginUrl toRecentLoginUrl() {
    return RecentLoginUrl(url, creationDate);
  }

  bool matchUrl(String pattern) {
    return url.toLowerCase().contains(pattern.toLowerCase());
  }
}

extension ListRecentLoginUrlCacheExtension on List<RecentLoginUrlCache> {

  void sortByCreationDate() {
    sort((recentUrl1, recentUrl2) {
      return recentUrl1.creationDate.compareToSort(recentUrl2.creationDate, false);
    });
  }
}

