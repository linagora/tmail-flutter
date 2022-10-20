import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';

part 'recent_login_url_cache.g.dart';

@HiveType(typeId: CachingConstants.LOGIN_URL_CACHE_IDENTITY)
class RecentLoginUrlCache extends HiveObject with EquatableMixin {
  
  @HiveField(0)
  final Uri url;

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

  bool matchUrl(Uri pattern) {
    return url.toString().toLowerCase().contains(pattern.toString().toLowerCase());
  }
}

