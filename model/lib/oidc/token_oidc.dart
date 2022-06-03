
import 'package:equatable/equatable.dart';
import 'package:model/oidc/token.dart';
import 'package:model/oidc/token_id.dart';

class TokenOIDC with EquatableMixin {

  final String token;
  final TokenId tokenId;
  final DateTime? expiredTime;
  final String refreshToken;

  TokenOIDC(
    this.token,
    this.tokenId,
    this.refreshToken,
    {this.expiredTime}
  );

  @override
  List<Object?> get props => [token, tokenId, expiredTime, refreshToken];
}

extension TokenOIDCExtension on TokenOIDC {

  bool isTokenValid() => token.isNotEmpty && tokenId.uuid.isNotEmpty;

  Token toToken() {
    return Token(token, tokenId, refreshToken, expiredTime: expiredTime);
  }

  String get tokenIdHash => tokenId.uuid.hashCode.toString();
}