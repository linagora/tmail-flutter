import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/fcm_api.dart';
import 'package:tmail_ui_user/features/push_notification/domain/extensions/firebase_subscription_extension.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class FcmDatasourceImpl extends FCMDatasource {

  final FcmApi _fcmApi;
  final ExceptionThrower _exceptionThrower;

  FcmDatasourceImpl(this._fcmApi, this._exceptionThrower);

  @override
  Future<FirebaseSubscription> getFirebaseSubscriptionByDeviceId(String deviceId) {
    return Future.sync(() async {
      return await _fcmApi.getFirebaseSubscriptionByDeviceId(deviceId);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<bool> deleteStateToRefresh(TypeName typeName) {
    throw UnimplementedError();
  }

  @override
  Future<jmap.State> getStateToRefresh(TypeName typeName) {
    throw UnimplementedError();
  }

  @override
  Future<bool> storeStateToRefresh(TypeName typeName, jmap.State newState) {
    throw UnimplementedError();
  }

  @override
  Future<FirebaseSubscription> registerNewToken(RegisterNewTokenRequest newTokenRequest) {
    return Future.sync(() async {
      final firebaseSubscription = await _fcmApi.registerNewToken(newTokenRequest);
      return firebaseSubscription.fromDeviceId(newDeviceId: newTokenRequest.firebaseSubscription.deviceClientId);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
  
  @override
  Future<bool> storeSubscription(FCMSubscriptionCache fcmSubscriptionCache) {
    throw UnimplementedError();
  }
  
  @override
  Future<FCMSubscriptionCache> geSubscription() {
    throw UnimplementedError();
  }
}