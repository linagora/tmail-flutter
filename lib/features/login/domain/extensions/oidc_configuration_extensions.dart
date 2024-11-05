
import 'package:core/data/model/query/query_parameter.dart';
import 'package:core/data/network/config/service_path.dart';
import 'package:core/utils/platform_info.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';
import 'package:tmail_ui_user/features/login/data/network/config/oidc_constant.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

extension OidcConfigurationExtensions on OIDCConfiguration {

  String get redirectUrl {
    if (PlatformInfo.isWeb) {
      return AppConfig.domainRedirectUrl.endsWith('/')
        ? AppConfig.domainRedirectUrl + loginRedirectOidcWeb
        : '${AppConfig.domainRedirectUrl}/$loginRedirectOidcWeb';
    } else {
      return authority == AppConfig.saasRegistrationUrl
        ? OIDCConstant.twakeWorkplaceRedirectUrl
        : redirectOidcMobile;
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
      return authority == AppConfig.saasRegistrationUrl
        ? OIDCConstant.twakeWorkplaceRedirectUrl
        : redirectOidcMobile;
  }
  }

  String get signInTWPUrl => ServicePath(authority)
    .withQueryParameters([
      StringQueryParameter(
        OIDCConstant.postLoginRedirectUrlPathParams,
        OIDCConstant.twakeWorkplaceRedirectUrl,
      ),
      StringQueryParameter('app', OIDCConstant.appParameter),
    ])
    .generateEndpointPath();

  String get signUpTWPUrl => ServicePath(authority)
    .withQueryParameters([
      StringQueryParameter(
        OIDCConstant.postRegisteredRedirectUrlPathParams,
        OIDCConstant.twakeWorkplaceRedirectUrl,
      ),
      StringQueryParameter('app', OIDCConstant.appParameter),
    ])
    .generateEndpointPath();
}