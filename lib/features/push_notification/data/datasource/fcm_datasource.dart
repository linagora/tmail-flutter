
import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:model/fcm/fcm_token_dto.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';

abstract class FCMDatasource {
  Future<FCMTokenDto> getFCMToken(String accountId);

  Future<void> setFCMToken(FCMTokenDto fcmToken);

  Future<void> deleteFCMToken(String accountId);

  Future<bool> storeStateToRefresh(TypeName typeName, jmap.State newState);

  Future<jmap.State> getStateToRefresh(TypeName typeName);

  Future<bool> deleteStateToRefresh(TypeName typeName);

  Future<bool> storeDeviceId(String deviceId);

  Future<FirebaseSubscription> getFirebaseSubscriptionByDeviceId(String deviceId);

  Future<FirebaseSubscription> registerNewToken(RegisterNewTokenRequest newTokenRequest);

  Future<String> getDeviceId();
}