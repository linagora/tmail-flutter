
import 'package:isar/isar.dart';

part 'token_oidc_collection.g.dart';

@collection
class TokenOidcCollection {

  Id get id => tokenId.hashCode;

  final String token;
  final String tokenId;
  final String refreshToken;
  final DateTime? expiredTime;

  TokenOidcCollection({
    required this.token,
    required this.tokenId,
    required this.refreshToken,
    required this.expiredTime,
  });
}
