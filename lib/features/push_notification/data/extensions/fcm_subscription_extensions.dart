

import 'package:tmail_ui_user/features/push_notification/data/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/fcm_subscription.dart';

extension FCMSubscriptionExtension on FCMSubscription {
  FCMSubscriptionCache toFCMSubscriptionCache() {
    return FCMSubscriptionCache(deviceId, subscriptionId);
  }
}
