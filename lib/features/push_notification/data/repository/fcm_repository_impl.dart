import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:core/utils/app_logger.dart';
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
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/email_property.dart';
import 'package:model/extensions/list_email_extension.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/email_changes_properties.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/register_new_token_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/update_token_expired_time_request.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/utils/fcm_constants.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_delegated_account.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/delegated_notification_baseline.dart';

class FCMRepositoryImpl extends FCMRepository {

  /// Key of the cursor a delegated mailbox starts from before its first push stores one.
  static const emailDeliveryBaseline = TypeName('EmailDeliveryBaseline');

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
    jmap.State currentState, {
    EmailChangesProperties? properties,
  }) async {
    final emailChangeResponse = await _threadDataSource.getAllEmailChanges(
      session,
      accountId,
      currentState,
      propertiesCreated: properties?.created,
      propertiesUpdated: properties?.updated,
    );

    final listEmails = emailChangeResponse?.created ?? [];
    listEmails.sortBy(EmailComparator(EmailComparatorProperty.receivedAt)..setIsAscending(true));

    if (listEmails.isNotEmpty) {
      return EmailsResponse(emailList: listEmails);
    } else {
      return const EmailsResponse();
    }
  }

  @override
  Future<void> storeStateToRefresh(AccountId accountId, UserName userName, TypeName typeName, jmap.State newState) {
    return _fcmDatasource[DataSourceType.local]!.storeStateToRefresh(accountId, userName, typeName, newState);
  }

  @override
  Future<jmap.State> getStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) async {
    try {
      return await _fcmDatasource[DataSourceType.local]!.getStateToRefresh(accountId, userName, typeName);
    } on NotFoundEmailDeliveryStateException {
      final baseline = await _storedEmailDeliveryBaseline(accountId, userName);
      if (baseline == null) rethrow;
      return baseline;
    }
  }

  /// Stands in for the cursor until a push stores one, so it is never written over a cursor.
  Future<jmap.State?> _storedEmailDeliveryBaseline(AccountId accountId, UserName userName) async {
    try {
      return await _fcmDatasource[DataSourceType.local]!.getStateToRefresh(accountId, userName, emailDeliveryBaseline);
    } on NotFoundStateToRefreshException {
      return null;
    }
  }

  @override
  Future<void> deleteStateToRefresh(AccountId accountId, UserName userName, TypeName typeName) async {
    await _fcmDatasource[DataSourceType.local]!.deleteStateToRefresh(accountId, userName, typeName);
    if (typeName == TypeName.emailDelivery) {
      await _fcmDatasource[DataSourceType.local]!.deleteStateToRefresh(accountId, userName, emailDeliveryBaseline);
    }
  }

  @override
  Future<FirebaseRegistration> getFirebaseRegistrationByDeviceId(DeviceClientId deviceId) {
    return _fcmDatasource[DataSourceType.network]!.getFirebaseRegistrationByDeviceId(deviceId);
  }

  @override
  Future<FirebaseRegistration> registerNewFirebaseRegistrationToken(RegisterNewTokenRequest newTokenRequest) {
    return _fcmDatasource[DataSourceType.network]!.registerNewFirebaseRegistrationToken(newTokenRequest);
  }

  @override
  Future<FirebaseRegistration> getStoredFirebaseRegistration()  {
    return _fcmDatasource[DataSourceType.local]!.getStoredFirebaseRegistration();
  }
  
  @override
  Future<void> storeFirebaseRegistration(FirebaseRegistration firebaseRegistration) {
    return _fcmDatasource[DataSourceType.local]!.storeFirebaseRegistration(firebaseRegistration);
  }
  
  @override
  Future<void> destroyFirebaseRegistration(FirebaseRegistrationId registrationId) {
    return _fcmDatasource[DataSourceType.network]!.destroyFirebaseRegistration(registrationId);
  }

  @override
  Future<List<PresentationMailbox>> getExcludedMailboxesForNotification(
    Session session,
    AccountId accountId,
  ) async {
    final mailboxesCache = await _mapMailboxDataSource[DataSourceType.local]!
        .getAllMailboxCache(accountId, session.username);

    // Use inbox presence as a cache quality signal; if inbox is cached,
    // the full mailbox structure is reliably available locally.
    if (mailboxesCache.any((m) => m.isInbox)) {
      final excluded = mailboxesCache
          .map((m) => m.toPresentationMailbox())
          .where((m) => m.pushNotificationDeactivated)
          .toList();
      log('FCMRepositoryImpl::getExcludedMailboxesForNotification(): cache hit — excluded=${excluded.length}');
      return excluded;
    }

    final mailboxResponse = await _mapMailboxDataSource[DataSourceType.network]!
        .getAllMailbox(session, accountId);
    final excluded = mailboxResponse.mailboxes
        .map((m) => m.toPresentationMailbox())
        .where((m) => m.pushNotificationDeactivated)
        .toList();
    log('FCMRepositoryImpl::getExcludedMailboxesForNotification(): network fetch — excluded=${excluded.length}');
    return excluded;
  }

  @override
  Future<List<EmailId>> getEmailChangesToRemoveNotification(
    Session session,
    AccountId accountId,
    jmap.State currentState, {
    EmailChangesProperties? properties,
  }) async {
    final emailChangeResponse = await _threadDataSource.getAllEmailChanges(
      session,
      accountId,
      currentState,
      propertiesCreated: properties?.created,
      propertiesUpdated: properties?.updated,
    );

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

  @override
  Future<List<EmailId>> getNewReceiveEmailFromNotification(Session session, AccountId accountId, jmap.State currentState) async {
    final changesResponse = await _threadDataSource.getChanges(
      session,
      accountId,
      currentState,
      propertiesCreated: Properties({
        EmailProperty.id,
        EmailProperty.receivedAt
      })
    );

    if (changesResponse.created?.isNotEmpty == true) {
      return _validateMaximumNewEmailsRetrieved(changesResponse.created!);
    } else {
      throw const NotFoundNewReceiveEmailException();
    }
  }

  List<EmailId> _validateMaximumNewEmailsRetrieved(List<Email> listEmails) {
    listEmails.sortBy(EmailComparator(EmailComparatorProperty.receivedAt));
    if (listEmails.length > FcmConstants.MAX_NUMBER_NEW_EMAILS_RETRIEVED) {
      final newListEmails = listEmails.sublist(0, FcmConstants.MAX_NUMBER_NEW_EMAILS_RETRIEVED);
      return newListEmails.listEmailIds;
    } else {
      return listEmails.listEmailIds;
    }
  }

  @override
  Future<void> updateFirebaseRegistrationToken(UpdateTokenExpiredTimeRequest expiredTimeRequest) {
    return _fcmDatasource[DataSourceType.network]!.updateFirebaseRegistrationToken(expiredTimeRequest);
  }

  @override
  Future<void> deleteFirebaseRegistrationCache() {
    return _fcmDatasource[DataSourceType.local]!.deleteFirebaseRegistrationCache();
  }

  @override
  Future<jmap.State?> getEmailState(Session session, AccountId accountId) {
    return _threadDataSource.getEmailState(session, accountId);
  }

  @override
  Future<Set<AccountId>> getDelegatedAccountIdsWithNotificationCursor(Session session) async {
    if (PlatformInfo.isIOS) {
      final stored = await _fcmDatasource[DataSourceType.local]!.getDelegatedAccountsInKeychain(session.accountId);
      return stored
          .where((account) => account.emailDeliveryState?.isNotEmpty == true)
          .map((account) => account.accountId)
          .toSet();
    }
    final accountIds = <AccountId>{};
    for (final accountId in session.delegatedAccounts.map((entry) => entry.key)) {
      try {
        await getStateToRefresh(accountId, session.username, TypeName.emailDelivery);
        accountIds.add(accountId);
      } on NotFoundEmailDeliveryStateException {
        continue;
      }
    }
    return accountIds;
  }

  @override
  Future<void> storeDelegatedNotificationBaselines(
    Session session,
    List<DelegatedNotificationBaseline> readBaselines,
  ) async {
    if (PlatformInfo.isIOS) {
      final baselines = await _keepingCursorsStoredMeanwhile(session, readBaselines);
      final delegatedAccounts = <KeychainDelegatedAccount>[];
      for (final baseline in baselines) {
        delegatedAccounts.add(KeychainDelegatedAccount(
          accountId: baseline.accountId,
          emailDeliveryState: baseline.state?.value,
          mailboxIdsBlockNotification: await _mailboxIdsBlockNotification(session, baseline.accountId),
          ownerName: baseline.ownerName,
        ));
      }
      await _fcmDatasource[DataSourceType.local]!
          .storeDelegatedAccountsInKeychain(session.accountId, delegatedAccounts);
      // The keychain keeps the stored list, but a first store has none, so the caller must retry.
      if (delegatedAccounts.any((account) => account.mailboxIdsBlockNotification == null)) {
        throw const NotFoundMailboxesBlockNotificationException();
      }
      return;
    }
    for (final baseline in readBaselines) {
      final state = baseline.state;
      if (state != null) {
        await storeStateToRefresh(baseline.accountId, session.username, emailDeliveryBaseline, state);
      }
    }
    // A mailbox notified again later must restart from the server state, not from the cursor it stopped at.
    final notifiedAccountIds = readBaselines.map((baseline) => baseline.accountId).toSet();
    for (final accountId in session.delegatedAccounts.map((entry) => entry.key)) {
      if (!notifiedAccountIds.contains(accountId)) {
        await deleteStateToRefresh(accountId, session.username, TypeName.emailDelivery);
      }
    }
  }

  /// The NSE may store a cursor while the baselines are read from the server, and that newer cursor wins.
  Future<List<DelegatedNotificationBaseline>> _keepingCursorsStoredMeanwhile(
    Session session,
    List<DelegatedNotificationBaseline> baselines,
  ) async {
    if (baselines.every((baseline) => baseline.state == null)) return baselines;
    final withCursor = await getDelegatedAccountIdsWithNotificationCursor(session);
    return baselines
        .map((baseline) => baseline.state != null && withCursor.contains(baseline.accountId)
            ? DelegatedNotificationBaseline(accountId: baseline.accountId, ownerName: baseline.ownerName)
            : baseline)
        .toList();
  }

  /// Null when the mailboxes cannot be read: the keychain keeps the stored list, and without one the NSE notifies every mailbox.
  Future<List<MailboxId>?> _mailboxIdsBlockNotification(Session session, AccountId accountId) async {
    try {
      final excluded = await getExcludedMailboxesForNotification(session, accountId);
      return excluded.map((mailbox) => mailbox.id).toList();
    } catch (e) {
      logWarning('FCMRepositoryImpl::_mailboxIdsBlockNotification: $e');
      return null;
    }
  }
}
