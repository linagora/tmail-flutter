
import 'package:equatable/equatable.dart';

class OIDCConfiguration with EquatableMixin {
  final redirectOidcMobile = 'teammail.mobile://oauthredirect';
  final wellKnownOpenId = '.well-known/openid-configuration';
  final loginRedirectOidcWeb = 'login-callback.html';
  final logoutRedirectOidcWeb = 'logout-callback.html';

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
      return '$authority/$wellKnownOpenId';
    }
  }

  @override
  List<Object?> get props => [
    authority,
    clientId,
    scopes
  ];
}
