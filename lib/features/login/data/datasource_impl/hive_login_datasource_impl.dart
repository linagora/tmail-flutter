import 'package:tmail_ui_user/features/caching/clients/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_datasource.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_username_cache.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/list_recent_login_url_extension.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/list_recent_login_username_extension.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveLoginDataSourceImpl implements LoginDataSource {
  
  final RecentLoginUrlCacheClient _recentLoginUrlCacheClient;
  final RecentLoginUsernameCacheClient _recentLoginUsernameCacheClient;
  final ExceptionThrower _exceptionThrower;

  HiveLoginDataSourceImpl(
    this._recentLoginUrlCacheClient,
    this._recentLoginUsernameCacheClient,
    this._exceptionThrower
  );
  
  @override
  Future<void> saveLoginUrl(RecentLoginUrl recentLoginUrl) {
    return Future.sync(() async {
      if (await _recentLoginUrlCacheClient.isExistItem(recentLoginUrl.url)) {
        return await _recentLoginUrlCacheClient.updateItem(
          recentLoginUrl.url,
          recentLoginUrl.toRecentLoginUrlCache()
        );
      } else {
        return await _recentLoginUrlCacheClient.insertItem(
          recentLoginUrl.url,
          recentLoginUrl.toRecentLoginUrlCache()
        );
      }
    }).catchError(_exceptionThrower.throwException);
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
    }).catchError(_exceptionThrower.throwException);
  }

  bool _filterRecentUrlCache(RecentLoginUrlCache recentLoginUrlCache, String? pattern) {
    if (pattern == null || pattern.trim().isEmpty) {
      return true;
    } else {
      return recentLoginUrlCache.matchUrl(pattern);
    }
  }

  @override
  Future<List<RecentLoginUsername>> getAllRecentLoginUsernamesLatest({int? limit, String? pattern}) {
    return Future.sync(() async {
      final listRecentUsernameCache = await _recentLoginUsernameCacheClient.getAll();
      final listValidRecentUsername = listRecentUsernameCache
        .where((recentCache) => _filterRecentLoginUsernameCache(recentCache, pattern))
        .map((recentCache) => recentCache.toRecentLoginUsername())
        .toList();

      listValidRecentUsername.sortByCreationDate();

      final newLimit = limit ?? 5;

      return listValidRecentUsername.length > newLimit
        ? listValidRecentUsername.sublist(0, newLimit)
        : listValidRecentUsername;
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveLoginUsername(RecentLoginUsername recentLoginUsername) {
    return Future.sync(() async {
      if (await _recentLoginUsernameCacheClient.isExistItem(recentLoginUsername.username)) {
        return await _recentLoginUsernameCacheClient.updateItem(
          recentLoginUsername.username,
          recentLoginUsername.toRecentLoginUsernameCache()
        );
      } else {
        return await _recentLoginUsernameCacheClient.insertItem(
          recentLoginUsername.username,
          recentLoginUsername.toRecentLoginUsernameCache()
        );
      }
    }).catchError(_exceptionThrower.throwException);
  }

  bool _filterRecentLoginUsernameCache(
    RecentLoginUsernameCache recentLoginUsernameCache,
    String? pattern
  ) {
    if (pattern == null || pattern.trim().isEmpty) {
      return true;
    } else {
      return recentLoginUsernameCache.matchUsername(pattern);
    }
  }

  @override
  Future<String> dnsLookupToGetJmapUrl(String emailAddress) {
    throw UnimplementedError();
  }
}