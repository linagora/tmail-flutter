import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
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

  TokenOidcCache(this.token, this.tokenId, this.refreshToken, {this.expiredTime});

  @override
  List<Object?> get props => [token, tokenId, expiredTime, refreshToken];
}