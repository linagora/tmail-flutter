import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'encryption_key_cache.g.dart';

@HiveType(typeId: CachingConstants.ENCRYPTION_KEY_HIVE_CACHE_IDENTIFY)
class EncryptionKeyCache extends HiveObject with EquatableMixin {

  static const String keyCacheValue = 'hiveEncryptionKey';

  @HiveField(0)
  final String value;

  EncryptionKeyCache(this.value);

  @override
  List<Object?> get props => [value];
}