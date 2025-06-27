
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'firebase_registration_cache.g.dart';

@HiveType(typeId: CachingConstants.FIREBASE_REGISTRATION_HIVE_CACHE_IDENTITY)
class FirebaseRegistrationCache extends HiveObject with EquatableMixin {

  static const String keyCacheValue = 'firebaseRegistrationCache';
  
  @HiveField(0)
  final String deviceClientId;

  @HiveField(1)
  final String? id;

  @HiveField(2)
  final String? token;

  @HiveField(3)
  final DateTime? expires;

  @HiveField(4)
  final List<String>? types;

  FirebaseRegistrationCache({
    required this.deviceClientId,
    this.id,
    this.token,
    this.expires,
    this.types
  });

  @override
  List<Object?> get props => [
    deviceClientId,
    id,
    token,
    expires,
    types
  ];
}