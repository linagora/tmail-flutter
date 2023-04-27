import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/utils/app_logger.dart';
import 'package:fcm/model/firebase_subscription.dart';
import 'package:fcm/model/type_name.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/extensions/list_email_extension.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/extensions/fcm_subscription_extensions.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/fcm_subscription.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/utils/fcm_constants.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';

class FCMRepositoryImpl extends FCMRepository {

  final Map<DataSourceType, FCMDatasource> _fcmDatasource;
  final ThreadDataSource _threadDataSource;
  final Map<DataSourceType, MailboxDataSource> _mapMailboxDataSource;

  FCMRepositoryImpl(
    this._fcmDatasource,
    this._threadDataSource,
    this._mapMailboxDataSource
  );

  @override
  Future<EmailsResponse> getEmailChangesToPushNotification(
    Session session,
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
        session,
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
  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState) {
    return _fcmDatasource[DataSourceType.local]!.storeStateToRefresh(accountId, userName, typeName, newState);
  }

  @override
  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) {
    return _fcmDatasource[DataSourceType.local]!.getStateToRefresh(accountId, userName, typeName);
  }

  @override
  Future<void> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) {
    return _fcmDatasource[DataSourceType.local]!.deleteStateToRefresh(accountId, userName, typeName);
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
    final fcmSubScription = await _fcmDatasource[DataSourceType.local]!.geSubscription();
    return FCMSubscription(fcmSubScription.deviceId, fcmSubScription.subscriptionId);
  }
  
  @override
  Future<void> storeSubscription(FCMSubscription fcmSubscription) {
    return _fcmDatasource[DataSourceType.local]!.storeSubscription(fcmSubscription.toFCMSubscriptionCache());
  }
  
  @override
  Future<bool> destroySubscription(String subscriptionId) {
    return _fcmDatasource[DataSourceType.network]!.destroySubscription(subscriptionId);
  }

  @override
  Future<List<PresentationMailbox>> getMailboxesNotPutNotifications(Session session, AccountId accountId) async {
    final mailboxesCache = await _mapMailboxDataSource[DataSourceType.local]!.getAllMailboxCache(accountId, session.username);
    final mailboxesCacheNotPutNotifications = mailboxesCache
      .map((mailbox) => mailbox.toPresentationMailbox())
      .where((presentationMailbox) => presentationMailbox.pushNotificationDeactivated)
      .toList();
    log('FCMRepositoryImpl::getMailboxesNotPutNotifications():mailboxesCacheNotPutNotifications: $mailboxesCacheNotPutNotifications');
    if (mailboxesCacheNotPutNotifications.isNotEmpty && mailboxesCacheNotPutNotifications.length == FcmConstants.mailboxRuleAllowPushNotifications.length) {
      return mailboxesCacheNotPutNotifications;
    } else {
      final mailboxResponse = await _mapMailboxDataSource[DataSourceType.network]!.getAllMailbox(session, accountId);
      final mailboxes = mailboxResponse.mailboxes ?? [];
      final mailboxesNotPutNotifications = mailboxes
        .map((mailbox) => mailbox.toPresentationMailbox())
        .where((presentationMailbox) => presentationMailbox.pushNotificationDeactivated)
        .toList();
      log('FCMRepositoryImpl::getMailboxesNotPutNotifications():mailboxesNotPutNotifications: $mailboxesNotPutNotifications');
      return mailboxesNotPutNotifications;
    }
  }

  @override
  Future<List<EmailId>> getEmailChangesToRemoveNotification(
    Session session,
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
        session,
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
      final listEmailIdMarkAsRead = emailChangeResponse.updated
        ?.where((email) => email.keywords?.containsKey(KeyWordIdentifier.emailSeen) == true)
        .toList()
        .listEmailIds ?? [];
      final listEmailIdDestroyed = emailChangeResponse.destroyed ?? [];
      log('FCMRepositoryImpl::getEmailChangesToRemoveNotification():listEmailIdMarkAsRead: $listEmailIdMarkAsRead | listEmailIdDestroyed: $listEmailIdDestroyed');
      final allListEmailIdsNeedRemove = listEmailIdMarkAsRead + listEmailIdDestroyed;
      return allListEmailIdsNeedRemove;
    } else {
      return [];
    }
  }
}