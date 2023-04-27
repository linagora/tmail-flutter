
import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';

abstract class FCMDatasource {
  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState);

  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName);

  Future<void> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName);

  Future<void> storeSubscription(FCMSubscriptionCache fcmSubscriptionCache);

  Future<FirebaseSubscription> getFirebaseSubscriptionByDeviceId(String deviceId);

  Future<FirebaseSubscription> registerNewToken(RegisterNewTokenRequest newTokenRequest);

  Future<FCMSubscriptionCache> geSubscription();

  Future<bool> destroySubscription(String subscriptionId);
}