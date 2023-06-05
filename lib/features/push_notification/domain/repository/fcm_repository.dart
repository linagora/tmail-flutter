import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

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

  Future<void> storeSubscription(FCMSubscription fcmSubscription);

  Future<FirebaseSubscription> getFirebaseSubscriptionByDeviceId(String deviceId);

  Future<FirebaseSubscription> registerNewToken(RegisterNewTokenRequest newTokenRequest);

  Future<FCMSubscription> getSubscription();

  Future<bool> destroySubscription(String subscriptionId);

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