import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'sentry_user_cache.g.dart';

@HiveType(typeId: CachingConstants.SENTRY_USER_CACHE_ID)
class SentryUserCache extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String email;

  SentryUserCache({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        email,
      ];
}
