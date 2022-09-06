import 'package:tmail_ui_user/features/caching/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';

class AuthenticationInfoCacheManager {
  final AuthenticationInfoCacheClient _authenticationInfoCacheClient;

  AuthenticationInfoCacheManager(this._authenticationInfoCacheClient);

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) {
    return _authenticationInfoCacheClient.insertItem(
        AuthenticationInfoCache.keyCacheValue,
        authenticationInfoCache);
  }

  Future<AuthenticationInfoCache?> getAuthenticationInfoStored() {
    return _authenticationInfoCacheClient.getItem(AuthenticationInfoCache.keyCacheValue);
  }
}