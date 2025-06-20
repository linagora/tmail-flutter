import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'authentication_info_cache.g.dart';

@HiveType(typeId: CachingConstants.AUTHENTICATION_INFO_HIVE_CACHE_IDENTIFY)
class AuthenticationInfoCache extends HiveObject with EquatableMixin {

  static const String keyCacheValue = 'authenticationInfoCache';

  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;

  AuthenticationInfoCache(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}