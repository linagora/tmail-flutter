
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/model/login_constants.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class CredentialRepositoryImpl extends CredentialRepository {

  final SharedPreferences sharedPreferences;
  final AuthenticationInfoCacheManager _authenticationInfoCacheManager;

  CredentialRepositoryImpl(
    this.sharedPreferences,
    this._authenticationInfoCacheManager
  );

  @override
  Future<Uri> getBaseUrl() async {
    return Uri.parse(sharedPreferences.getString(LoginConstants.KEY_BASE_URL) ?? '');
  }

  @override
  Future saveBaseUrl(Uri baseUrl) async {
    await sharedPreferences.setString(LoginConstants.KEY_BASE_URL, baseUrl.toString());
  }

  @override
  Future removeBaseUrl() async {
    await sharedPreferences.remove(LoginConstants.KEY_BASE_URL);
  }

  @override
  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) {
    return _authenticationInfoCacheManager.storeAuthenticationInfo(authenticationInfoCache);
  }

  @override
  Future<AuthenticationInfoCache?> getAuthenticationInfoStored({bool needToReopen = false}) {
    return _authenticationInfoCacheManager.getAuthenticationInfoStored(needToReopen: needToReopen);
  }

  @override
  Future<void> removeAuthenticationInfo() {
    return _authenticationInfoCacheManager.removeAuthenticationInfo();
  }
}