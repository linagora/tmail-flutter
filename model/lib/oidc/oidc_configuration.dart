
import 'package:equatable/equatable.dart';

class OIDCConfiguration with EquatableMixin {
  static const String _wellKnownOpenId = '.well-known/openid-configuration';

  final String authority;
  final String clientId;
  final List<String> scopes;
  final bool isTWP;
  final String? loginHint;

  /// Whether webFinger actually advertised SSO for this server.
  ///
  /// `true` means SSO was confirmed by discovery; `false` means the provider was
  /// only guessed from the base URL, so the server may not be an SSO server and
  /// basic auth remains a legitimate fallback when authentication fails.
  final bool ssoConfirmed;

  OIDCConfiguration({
    required this.authority,
    required this.clientId,
    required this.scopes,
    this.isTWP = false,
    this.loginHint,
    this.ssoConfirmed = false,
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
    ssoConfirmed,
  ];
}

extension OIDCConfigurationExtension on OIDCConfiguration {
  OIDCConfiguration copyWidth({
    String? authority,
    String? clientId,
    List<String>? scopes,
    bool? isTWP,
    String? loginHint,
    bool? ssoConfirmed,
  }) =>
      OIDCConfiguration(
        authority: authority ?? this.authority,
        clientId: clientId ?? this.clientId,
        scopes: scopes ?? this.scopes,
        isTWP: isTWP ?? this.isTWP,
        loginHint: loginHint ?? this.loginHint,
        ssoConfirmed: ssoConfirmed ?? this.ssoConfirmed,
      );
}
