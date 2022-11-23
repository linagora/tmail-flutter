import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'fcm_token_cache.g.dart';

@HiveType(typeId: CachingConstants.FCM_TOKEN_CACHE_IDENTITY)
class FCMTokenCache extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String token;

  @HiveField(1)
  final String accountId;

  FCMTokenCache(
    this.token,
    this.accountId,
  );

  @override
  List<Object?> get props => [token, accountId];
}
