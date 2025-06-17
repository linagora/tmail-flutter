import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'email_address_hive_cache.g.dart';

@HiveType(typeId: CachingConstants.EMAIL_ADDRESS_HIVE_CACHE_IDENTIFY)
class EmailAddressHiveCache extends HiveObject with EquatableMixin {

  @HiveField(0)
  final String? name;

  @HiveField(1)
  final String? email;

  EmailAddressHiveCache(this.name, this.email);

  @override
  List<Object?> get props => [name, email];
}