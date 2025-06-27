import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_url_cache_manager.dart';
import 'package:tmail_ui_user/features/cleanup/data/local/recent_login_username_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/datasource/login_datasource.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveLoginDataSourceImpl implements LoginDataSource {
  
  final RecentLoginUrlCacheManager _recentLoginUrlCacheManager;
  final RecentLoginUsernameCacheManager _recentLoginUsernameCacheManager;
  final ExceptionThrower _exceptionThrower;

  HiveLoginDataSourceImpl(
    this._recentLoginUrlCacheManager,
    this._recentLoginUsernameCacheManager,
    this._exceptionThrower
  );
  
  @override
  Future<void> saveLoginUrl(RecentLoginUrl recentLoginUrl) {
    return Future.sync(() async {
      return await _recentLoginUrlCacheManager.saveLoginUrl(
        recentLoginUrl.toRecentLoginUrlCache(),
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<RecentLoginUrl>> getAllRecentLoginUrlLatest({int? limit, String? pattern}) {
    return Future.sync(() async {
      return await _recentLoginUrlCacheManager.getAllRecentLoginUrlLatest(
        limit: limit,
        pattern: pattern,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<RecentLoginUsername>> getAllRecentLoginUsernamesLatest({int? limit, String? pattern}) {
    return Future.sync(() async {
      return await _recentLoginUsernameCacheManager.getAllRecentLoginUsernamesLatest(
        limit: limit,
        pattern: pattern,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> saveLoginUsername(RecentLoginUsername recentLoginUsername) {
    return Future.sync(() async {
      return await _recentLoginUsernameCacheManager.saveLoginUsername(
        recentLoginUsername,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<String> dnsLookupToGetJmapUrl(String emailAddress) {
    throw UnimplementedError();
  }
}