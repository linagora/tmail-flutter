import 'package:equatable/equatable.dart';

class TokenRequest with EquatableMixin {
  final String? clientId;
  final String? redirectUrl;
  final String? grantType;
  final String? authorizationCode;
  final String? codeVerifier;
  final String? refreshToken;
  final List<String>? scopes;

  TokenRequest({
    this.clientId,
    this.redirectUrl,
    this.grantType,
    this.authorizationCode,
    this.codeVerifier,
    this.refreshToken,
    this.scopes,
  });

  @override
  List<Object?> get props => [clientId, redirectUrl, grantType, authorizationCode, codeVerifier, refreshToken];
}