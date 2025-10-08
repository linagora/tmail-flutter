
import 'package:equatable/equatable.dart';

class OIDCConfiguration with EquatableMixin {
  static const String _wellKnownOpenId = '.well-known/openid-configuration';

  final String authority;
  final String clientId;
  final List<String> scopes;
  final bool isTWP;
  final String? loginHint;

  OIDCConfiguration({
    required this.authority,
    required this.clientId,
    required this.scopes,
    this.isTWP = false,
    this.loginHint,
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
    loginHint,
  ];
}

extension OIDCConfigurationExtension on OIDCConfiguration {
  OIDCConfiguration copyWidth({
    String? authority,
    String? clientId,
    List<String>? scopes,
    bool? isTWP,
    String? loginHint,
  }) =>
      OIDCConfiguration(
        authority: authority ?? this.authority,
        clientId: clientId ?? this.clientId,
        scopes: scopes ?? this.scopes,
        isTWP: isTWP ?? this.isTWP,
        loginHint: loginHint ?? this.loginHint,
      );
}
