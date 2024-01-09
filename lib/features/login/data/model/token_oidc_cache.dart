import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'token_oidc_cache.g.dart';

@HiveType(typeId: CachingConstants.TOKEN_OIDC_HIVE_CACHE_IDENTIFY)
class TokenOidcCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String token;

  @HiveField(1)
  final String tokenId;

  @HiveField(2)
  final DateTime? expiredTime;

  @HiveField(3)
  final String refreshToken;

  @HiveField(4)
  final String authority;

  TokenOidcCache({
    required this.token,
    required this.tokenId,
    required this.refreshToken,
    required this.authority,
    this.expiredTime
  });

  @override
  List<Object?> get props => [
    tokenId,
    token,
    refreshToken,
    expiredTime,
    authority,
  ];
}

extension TokenOidcCacheExtension on TokenOidcCache {
  TokenOIDC toTokenOIDC() =>
    TokenOIDC(
      token: token,
      tokenId: TokenId(tokenId),
      refreshToken: refreshToken,
      authority: authority,
      expiredTime: expiredTime
    );
}