
import 'package:core/utils/build_utils.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

extension OidcConfigurationExtensions on OIDCConfiguration {

  String get redirectUrl {
    if (BuildUtils.isWeb) {
      if (AppConfig.domainRedirectUrl.endsWith('/')) {
        return AppConfig.domainRedirectUrl + loginRedirectOidcWeb;
      } else {
        return AppConfig.domainRedirectUrl + '/' + loginRedirectOidcWeb;
      }
    } else {
      return redirectOidcMobile;
    }
  }

  String get logoutRedirectUrl {
    if (BuildUtils.isWeb) {
      if (AppConfig.domainRedirectUrl.endsWith('/')) {
        return AppConfig.domainRedirectUrl + logoutRedirectOidcWeb;
      } else {
        return AppConfig.domainRedirectUrl + '/' + logoutRedirectOidcWeb;
      }
    } else {
      return redirectOidcMobile;
    }
  }
}