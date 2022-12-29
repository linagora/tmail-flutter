import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/fcm_subscription_extensions.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';

class FCMRepositoryImpl extends FCMRepository {

  final Map<DataSourceType, FCMDatasource> _fcmDatasource;
  final ThreadDataSource _threadDataSource;

  FCMRepositoryImpl(
    this._fcmDatasource,
    this._threadDataSource
  );

  @override
  Future<EmailsResponse> getEmailChangesToPushNotification(
    AccountId accountId,
    jmap.State currentState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated
    }
  ) async {
    EmailChangeResponse? emailChangeResponse;
    bool hasMoreChanges = true;
    jmap.State? sinceState = currentState;

    while (hasMoreChanges && sinceState != null) {
      final changesResponse = await _threadDataSource.getChanges(
        accountId,
        sinceState,
        propertiesCreated: propertiesCreated,
        propertiesUpdated: propertiesUpdated
      );

      hasMoreChanges = changesResponse.hasMoreChanges;
      sinceState = changesResponse.newStateChanges;

      if (emailChangeResponse != null) {
        emailChangeResponse.union(changesResponse);
      } else {
        emailChangeResponse = changesResponse;
      }
    }

    if (emailChangeResponse != null) {
      return EmailsResponse(emailList: emailChangeResponse.created ?? []);
    } else {
      return EmailsResponse();
    }
  }

  @override
  Future<bool> storeStateToRefresh(TypeName typeName, jmap.State newState) {
    return _fcmDatasource[DataSourceType.local]!.storeStateToRefresh(typeName, newState);
  }

  @override
  Future<jmap.State> getStateToRefresh(TypeName typeName) {
    return _fcmDatasource[DataSourceType.local]!.getStateToRefresh(typeName);
  }

  @override
  Future<bool> deleteStateToRefresh(TypeName typeName) {
    return _fcmDatasource[DataSourceType.local]!.deleteStateToRefresh(typeName);
  }

  @override
  Future<FirebaseSubscription> getFirebaseSubscriptionByDeviceId(String deviceId) {
    return _fcmDatasource[DataSourceType.network]!.getFirebaseSubscriptionByDeviceId(deviceId);
  }

  @override
  Future<FirebaseSubscription> registerNewToken(RegisterNewTokenRequest newTokenRequest) {
    return _fcmDatasource[DataSourceType.network]!.registerNewToken(newTokenRequest);
  }

  @override
  Future<FCMSubscription> getSubscription() async {
    final _fcmSubScription = await _fcmDatasource[DataSourceType.local]!.geSubscription();
    return FCMSubscription(_fcmSubScription.deviceId, _fcmSubScription.subscriptionId);
  }
  
  @override
  Future<void> storeSubscription(FCMSubscription fcmSubscription) {
    return _fcmDatasource[DataSourceType.local]!.storeSubscription(fcmSubscription.toFCMSubscriptionCache());
  }
  
  @override
  Future<bool> destroySubscription(String subscriptionId) {
    return _fcmDatasource[DataSourceType.network]!.destroySubscription(subscriptionId);
  }
}