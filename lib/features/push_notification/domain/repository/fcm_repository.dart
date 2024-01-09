import 'package:fcm/model/device_client_id.dart';
import 'package:fcm/model/firebase_registration.dart';
import 'package:fcm/model/firebase_registration_id.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/update_token_expired_time_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';

abstract class FCMRepository {
  Future<EmailsResponse> getEmailChangesToPushNotification(
    Session session,
    AccountId accountId,
    jmap.State currentState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated
    }
  );

  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState);

  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName);

  Future<void> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName);

  Future<void> storeFirebaseRegistration(AccountId accountId, UserName userName, FirebaseRegistration firebaseRegistration);

  Future<FirebaseRegistration> getFirebaseRegistrationByDeviceId(DeviceClientId deviceId);

  Future<FirebaseRegistration> registerNewFirebaseRegistrationToken(RegisterNewTokenRequest newTokenRequest);

  Future<FirebaseRegistration> getStoredFirebaseRegistration(AccountId accountId, UserName userName);

  Future<void> deleteFirebaseRegistrationCache(AccountId accountId, UserName userName);

  Future<void> destroyFirebaseRegistration(FirebaseRegistrationId registrationId);

  Future<void> updateFirebaseRegistrationToken(UpdateTokenExpiredTimeRequest expiredTimeRequest);

  Future<List<PresentationMailbox>> getMailboxesNotPutNotifications(Session session, AccountId accountId);

  Future<List<EmailId>> getEmailChangesToRemoveNotification(
    Session session,
    AccountId accountId,
    jmap.State currentState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated
    }
  );

  Future<List<EmailId>> getNewReceiveEmailFromNotification(Session session, AccountId accountId, jmap.State currentState);
}