import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/basic_auth.dart';
import 'package:model/account/password.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'basic_auth_cache.g.dart';

@HiveType(typeId: CachingConstants.BASIC_AUTH_HIVE_CACHE_IDENTIFY)
class BasicAuthCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String username;

  @HiveField(1)
  final String password;

  BasicAuthCache(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

extension BasicAuthCacheExtension on BasicAuthCache {
  BasicAuth toBasicAuth() => BasicAuth(UserName(username), Password(password));
}