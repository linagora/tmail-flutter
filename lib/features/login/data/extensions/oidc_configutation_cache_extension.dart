
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/data/model/oidc_configuration_cache.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

extension OidcConfigutationCacheExtension on OidcConfigurationCache {
  OIDCConfiguration toOIDCConfiguration() {
    return OIDCConfiguration(
      authority: authority,
      isTWP: isTWP,
      clientId: OIDCConstant.clientId,
      scopes: AppConfig.oidcScopes,
    );
  }
}