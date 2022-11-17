import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'firebase_cache.g.dart';

@HiveType(typeId: CachingConstants.FIREBASE_CONFIG_CACHE_IDENTITY)
class FirebaseCache extends HiveObject with EquatableMixin {

  static const String keyCacheValue = 'firebaseCache';

  @HiveField(0)
  final String token;

  FirebaseCache(this.token);

  @override
  List<Object?> get props => [token];
}