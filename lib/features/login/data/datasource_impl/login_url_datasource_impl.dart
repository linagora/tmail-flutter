import 'package:tmail_ui_user/features/caching/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_url_datasource.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/list_recent_login_url_extension.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LoginUrlDataSourceImpl implements LoginUrlDataSource {
  
  final RecentLoginUrlCacheClient _recentLoginUrlCacheClient;
  final ExceptionThrower _exceptionThrower;

  LoginUrlDataSourceImpl(this._recentLoginUrlCacheClient, this._exceptionThrower);
  
  @override
  Future<void> saveLoginUrl(RecentLoginUrl recentLoginUrl) {
    return Future.sync(() async {
      if (await _recentLoginUrlCacheClient.isExistItem(recentLoginUrl.url)) {
        await _recentLoginUrlCacheClient.updateItem(
            recentLoginUrl.url,
            recentLoginUrl.toRecentLoginUrlCache());
      } else {
        await _recentLoginUrlCacheClient.insertItem(
            recentLoginUrl.url,
            recentLoginUrl.toRecentLoginUrlCache());
      }
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<List<RecentLoginUrl>> getAllRecentLoginUrlLatest({int? limit, String? pattern}) {
    return Future.sync(() async {
      final listRecentUrlCache = await _recentLoginUrlCacheClient.getAll();
      final listRecentUrl = listRecentUrlCache
          .where((recentCache) => _filterRecentUrlCache(recentCache, pattern))
          .map((recentCache) => recentCache.toRecentLoginUrl())
          .toList();
      listRecentUrl.sortByCreationDate();

      final newLimit = limit ?? 5;

      final newListRecentSUrl = listRecentUrl.length > newLimit
          ? listRecentUrl.sublist(0, newLimit)
          : listRecentUrl;

      return newListRecentSUrl;
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  bool _filterRecentUrlCache(RecentLoginUrlCache recentLoginUrlCache, String? pattern) {
    if (pattern == null || pattern.trim().isEmpty) {
      return true;
    } else {
      return recentLoginUrlCache.matchUrl(pattern);
    }
  }
}