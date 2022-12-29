
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

part 'fcm_subscription.g.dart';

@HiveType(typeId: CachingConstants.FCM_SUBSCRIPTION_HIVE_CACHE_INDENTITY)
class FCMSubscriptionCache extends HiveObject with EquatableMixin {

  static const String keyCacheValue = 'fcmSubscriptionCache';
  
  @HiveField(0)
  final String deviceId;

  @HiveField(1)
  final String subscriptionId;

  FCMSubscriptionCache(this.deviceId, this.subscriptionId);

  @override
  List<Object?> get props => [deviceId, subscriptionId];
}