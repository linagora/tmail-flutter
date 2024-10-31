import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class OIDCConstant {
  static String get mobileOidcClientId => 'teammail-mobile';
  static List<String> get oidcScope => ['openid', 'profile', 'email', 'offline_access'];
  static const keyAuthorityOidc = 'KEY_AUTHORITY_OIDC';
  static const authResponseKey = "auth_info";
  static const String twakeWorkplaceUrlScheme = 'twakemail.mobile';
  static const String twakeWorkplaceRedirectUrl = '$twakeWorkplaceUrlScheme://redirect';
  static const String appParameter = 'tmail';
  static const String postRegisteredRedirectUrlPathParams = 'post_registered_redirect_url';
  static const String postLoginRedirectUrlPathParams = 'post_login_redirect_url';

  static String get clientId => PlatformInfo.isWeb ? AppConfig.webOidcClientId : mobileOidcClientId;
}