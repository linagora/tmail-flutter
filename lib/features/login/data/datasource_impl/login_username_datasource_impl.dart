import 'package:tmail_ui_user/features/caching/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_username_datasource.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_username_cache.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/list_recent_login_username_extension.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LoginUsernameDataSourceImpl implements LoginUsernameDataSource {

  final RecentLoginUsernameCacheClient _recentLoginUsernameCacheClient;
  final ExceptionThrower _exceptionThrower;

  LoginUsernameDataSourceImpl(this._recentLoginUsernameCacheClient, this._exceptionThrower);

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
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<void> saveLoginUsername(RecentLoginUsername recentLoginUsername) {
    return Future.sync(() async {
      if (await _recentLoginUsernameCacheClient
          .isExistItem(recentLoginUsername.username)) {
        await _recentLoginUsernameCacheClient.updateItem(recentLoginUsername.username,
            recentLoginUsername.toRecentLoginUsernameCache());
      } else {
        await _recentLoginUsernameCacheClient.insertItem(recentLoginUsername.username,
            recentLoginUsername.toRecentLoginUsernameCache());
      }
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
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
}
