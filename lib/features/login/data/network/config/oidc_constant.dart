import 'package:core/core.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class OIDCConstant {
  static String get mobileOidcClientId => 'teammail-mobile';
  static List<String> get oidcScope => ['openid', 'profile', 'email', 'offline_access'];
  static const keyAuthorityOidc = 'KEY_AUTHORITY_OIDC';
  static const authResponseKey = "auth_info";

  static String get clientId => PlatformInfo.isWeb ? AppConfig.webOidcClientId : mobileOidcClientId;

  static String get saasClientId => PlatformInfo.isMobile
    ? mobileOidcClientId
    : '';
}