
import 'package:equatable/equatable.dart';

class OIDCConfiguration with EquatableMixin {
  static const String _wellKnownOpenId = '.well-known/openid-configuration';

  final String authority;
  final String clientId;
  final List<String> scopes;
  final bool isTWP;

  OIDCConfiguration({
    required this.authority,
    required this.clientId,
    required this.scopes,
    this.isTWP = false,
  });

  String get discoveryUrl {
    if (authority.endsWith('/')) {
      return authority + _wellKnownOpenId;
    } else {
      return '$authority/$_wellKnownOpenId';
    }
  }

  @override
  List<Object?> get props => [
    authority,
    clientId,
    scopes,
    isTWP,
  ];
}
