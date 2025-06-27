import 'package:core/utils/app_logger.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/caching/clients/oidc_configuration_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/login/data/extensions/oidc_configutation_cache_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_error.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class OidcConfigurationCacheManager extends CacheManagerInteraction {
  final SharedPreferences _sharedPreferences;
  final OidcConfigurationCacheClient _oidcConfigurationCacheClient;

  OidcConfigurationCacheManager(this._sharedPreferences, this._oidcConfigurationCacheClient);

  Future<OIDCConfiguration> getOidcConfiguration() async {
    final oidcConfigurationCache = await _oidcConfigurationCacheClient.getItem(CachingConstants.oidcConfigurationCacheKeyName);
    if (oidcConfigurationCache == null) {
      final authority = _sharedPreferences.getString(OIDCConstant.keyAuthorityOidc);

      if (authority == null || authority.isEmpty) {
        throw CanNotFoundOIDCAuthority();
      }

      return OIDCConfiguration(
        authority: authority,
        clientId: OIDCConstant.clientId,
        scopes: AppConfig.oidcScopes,
      );
    } else {
      return oidcConfigurationCache.toOIDCConfiguration();
    }
  }

  Future<void> persistOidcConfiguration(OIDCConfiguration oidcConfiguration) async {
    log('OidcConfigurationCacheManager::persistOidcConfiguration(): $oidcConfiguration');
    await _oidcConfigurationCacheClient.insertItem(
      CachingConstants.oidcConfigurationCacheKeyName,
      oidcConfiguration.toOidcConfigurationCache(),
    );
  }

  Future<void> deleteOidcConfiguration() async {
    log('OidcConfigurationCacheManager::deleteOidcConfiguration()');
    await Future.wait([
      _oidcConfigurationCacheClient.deleteItem(
        CachingConstants.oidcConfigurationCacheKeyName,
      ),
      _sharedPreferences.remove(OIDCConstant.keyAuthorityOidc),
    ]);
  }

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _oidcConfigurationCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _oidcConfigurationCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_oidcConfigurationCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_oidcConfigurationCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}