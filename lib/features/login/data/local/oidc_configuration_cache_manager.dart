import 'package:core/utils/app_logger.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class OidcConfigurationCacheManager {
  final SharedPreferences _sharedPreferences;

  OidcConfigurationCacheManager(this._sharedPreferences);

  Future<OIDCConfiguration> getOidcConfiguration() async {
    final authority = _sharedPreferences.getString(OIDCConstant.keyAuthorityOidc);
    if (authority == null || authority.isEmpty) {
      throw CanNotFoundOIDCAuthority();
    } else {
      return OIDCConfiguration(
          authority: authority,
          clientId: OIDCConstant.clientId,
          scopes: AppConfig.oidcScopes);
    }
  }

  Future<void> persistAuthorityOidc(String authority) async {
    log('OidcConfigurationCacheManager::persistAuthorityOidc(): $authority');
    await _sharedPreferences.setString(OIDCConstant.keyAuthorityOidc, authority);
  }

  Future<void> deleteAuthorityOidc() async {
    log('OidcConfigurationCacheManager::deleteAuthorityOidc()');
    await _sharedPreferences.remove(OIDCConstant.keyAuthorityOidc);
  }
}