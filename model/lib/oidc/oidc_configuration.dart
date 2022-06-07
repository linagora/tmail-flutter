
import 'package:core/utils/build_utils.dart';
import 'package:equatable/equatable.dart';

class OIDCConfiguration with EquatableMixin {
  static const redirectOidcMobile = 'teammail.mobile://oauthredirect';
  static const redirectOidcWeb = 'http://localhost:3000/login-callback.html';
  static const wellKnownOpenId = '.well-known/openid-configuration';

  final String authority;
  final String clientId;
  final List<String> scopes;

  OIDCConfiguration({
    required this.authority,
    required this.clientId,
    required this.scopes
  });

  String get discoveryUrl {
    if (authority.endsWith('/')) {
      return authority + wellKnownOpenId;
    } else {
      return authority + '/' + wellKnownOpenId;
    }
  }

  String get redirectUrl => BuildUtils.isWeb ? redirectOidcWeb : redirectOidcMobile;

  String get clientIdHash => clientId.hashCode.toString();

  @override
  List<Object?> get props => [
    authority,
    clientId,
    scopes
  ];
}
