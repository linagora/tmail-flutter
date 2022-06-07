import 'package:core/core.dart';

class OIDCConstant {
  static String get mobileOidcClientId => 'teammail-mobile';
  static String get webOidcClientId => 'teammail-web';
  static List<String> get oidcScope => ['openid', 'offline_access'];
  static const keyAuthorityOidc = 'KEY_AUTHORITY_OIDC';
  static const authResponseKey = "auth_info";

  static String get clientId => BuildUtils.isWeb ? webOidcClientId : mobileOidcClientId;
}