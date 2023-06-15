
import 'package:core/utils/platform_info.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

extension OidcConfigurationExtensions on OIDCConfiguration {

  String get redirectUrl {
    if (PlatformInfo.isWeb) {
      if (AppConfig.domainRedirectUrl.endsWith('/')) {
        return AppConfig.domainRedirectUrl + loginRedirectOidcWeb;
      } else {
        return '${AppConfig.domainRedirectUrl}/$loginRedirectOidcWeb';
      }
    } else {
      return redirectOidcMobile;
    }
  }

  String get logoutRedirectUrl {
    if (PlatformInfo.isWeb) {
      if (AppConfig.domainRedirectUrl.endsWith('/')) {
        return AppConfig.domainRedirectUrl + logoutRedirectOidcWeb;
      } else {
        return '${AppConfig.domainRedirectUrl}/$logoutRedirectOidcWeb';
      }
    } else {
      return redirectOidcMobile;
    }
  }
}