import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'oidc_configuration_cache.g.dart';

@HiveType(typeId: CachingConstants.OIDC_CONFIGURATION_CACHE_ID)
class OidcConfigurationCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String authority;

  @HiveField(1)
  final bool isTWP;

  OidcConfigurationCache(this.authority, this.isTWP);

  @override
  List<Object?> get props => [authority, isTWP];
}