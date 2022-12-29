
import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';

abstract class FCMDatasource {
  Future<bool> storeStateToRefresh(TypeName typeName, jmap.State newState);

  Future<jmap.State> getStateToRefresh(TypeName typeName);

  Future<bool> deleteStateToRefresh(TypeName typeName);

  Future<void> storeSubscription(FCMSubscriptionCache fcmSubscriptionCache);

  Future<FirebaseSubscription> getFirebaseSubscriptionByDeviceId(String deviceId);

  Future<FirebaseSubscription> registerNewToken(RegisterNewTokenRequest newTokenRequest);

  Future<FCMSubscriptionCache> geSubscription();

  Future<bool> destroySubscription(String subscriptionId);
}