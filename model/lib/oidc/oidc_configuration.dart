
import 'package:equatable/equatable.dart';

class OIDCConfiguration with EquatableMixin {
  static const redirectOidc = 'teammail.mobile://oauthredirect';
  static const wellKnownOpenId = '.well-known/openid-configuration';

  final String authority;
  final String clientId;
  final String redirectUrl = redirectOidc;
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

  @override
  List<Object?> get props => [
    authority,
    clientId,
    scopes
  ];
}
