
import 'package:equatable/equatable.dart';
import 'package:model/oidc/token_id.dart';

class Token extends Equatable {
  const Token(this.token, this.tokenId);

  final String token;
  final TokenId tokenId;

  @override
  List<Object> get props => [token, tokenId];
}

extension TokenExtension on Token {
  bool isTokenValid() => token.isNotEmpty && tokenId.uuid.isNotEmpty;
}
