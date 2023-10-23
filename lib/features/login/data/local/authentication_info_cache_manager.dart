import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class AuthenticationInfoCacheManager {
  final AuthenticationInfoCacheClient _authenticationInfoCacheClient;

  AuthenticationInfoCacheManager(this._authenticationInfoCacheClient);

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) {
    return _authenticationInfoCacheClient.insertItem(
        AuthenticationInfoCache.keyCacheValue,
        authenticationInfoCache);
  }

  Future<AuthenticationInfoCache> getAuthenticationInfoStored() async {
    final authenticationInfoCache = await _authenticationInfoCacheClient.getItem(AuthenticationInfoCache.keyCacheValue);
    if (authenticationInfoCache != null) {
      return authenticationInfoCache;
    } else {
      throw NotFoundAuthenticationInfoCache();
    }
  }

  Future<void> removeAuthenticationInfo() {
    return _authenticationInfoCacheClient.deleteItem(AuthenticationInfoCache.keyCacheValue);
  }
}