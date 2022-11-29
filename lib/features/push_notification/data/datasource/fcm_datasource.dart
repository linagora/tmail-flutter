
import 'package:fcm/model/type_name.dart';
import 'package:model/fcm/fcm_token_dto.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

abstract class FCMDatasource {
  Future<FCMTokenDto> getFCMToken(String accountId);

  Future<void> setFCMToken(FCMTokenDto fcmToken);

  Future<void> deleteFCMToken(String accountId);

  Future<bool> storeStateToRefresh(TypeName typeName, jmap.State newState);

  Future<jmap.State> getStateToRefresh(TypeName typeName);

  Future<bool> deleteStateToRefresh(TypeName typeName);

  Future<bool> storeDeviceId(String deviceId);
}