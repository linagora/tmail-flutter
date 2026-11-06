import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/new_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/sending_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_account_key.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/composer_snapshot_policy.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_cleanup.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_notification.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/ended_delegation_store.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/new_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/opened_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:universal_html/html.dart' as html;

/// Deletes local data of an account the session no longer lists.
///
/// shortcut: scans account-keyed cache boxes on each online session read,
/// replace with a written index if that scan gets slow.
class EndedDelegationStoreImpl implements EndedDelegationStore {
  final MailboxCacheClient _mailboxCacheClient;
  final EmailCacheClient _emailCacheClient;
  final StateCacheClient _stateCacheClient;
  final NewEmailHiveCacheClient _newEmailCacheClient;
  final OpenedEmailHiveCacheClient _openedEmailCacheClient;
  final SendingEmailHiveCacheClient _sendingEmailCacheClient;
  final FcmCacheClient _fcmCacheClient;
  final ComposerHiveCacheClient? _composerHiveCacheClient;
  final EmailCacheManager _emailCacheManager;
  final NewEmailCacheManager _newEmailCacheManager;
  final OpenedEmailCacheManager _openedEmailCacheManager;
  final KeychainSharingManager _keychainSharingManager;
  final FileUtils _fileUtils;

  EndedDelegationStoreImpl({
    required MailboxCacheClient mailboxCacheClient,
    required EmailCacheClient emailCacheClient,
    required StateCacheClient stateCacheClient,
    required NewEmailHiveCacheClient newEmailCacheClient,
    required OpenedEmailHiveCacheClient openedEmailCacheClient,
    required SendingEmailHiveCacheClient sendingEmailCacheClient,
    required FcmCacheClient fcmCacheClient,
    required EmailCacheManager emailCacheManager,
    required NewEmailCacheManager newEmailCacheManager,
    required OpenedEmailCacheManager openedEmailCacheManager,
    required KeychainSharingManager keychainSharingManager,
    required FileUtils fileUtils,
    ComposerHiveCacheClient? composerHiveCacheClient,
  })  : _mailboxCacheClient = mailboxCacheClient,
        _emailCacheClient = emailCacheClient,
        _stateCacheClient = stateCacheClient,
        _newEmailCacheClient = newEmailCacheClient,
        _openedEmailCacheClient = openedEmailCacheClient,
        _sendingEmailCacheClient = sendingEmailCacheClient,
        _fcmCacheClient = fcmCacheClient,
        _composerHiveCacheClient = composerHiveCacheClient,
        _emailCacheManager = emailCacheManager,
        _newEmailCacheManager = newEmailCacheManager,
        _openedEmailCacheManager = openedEmailCacheManager,
        _keychainSharingManager = keychainSharingManager,
        _fileUtils = fileUtils;

  static final _composerKeyPrefix =
      '${EmailActionType.reopenComposerBrowser.name}|';

  List<_KeyedBox> get _boxes {
    final composer = _composerHiveCacheClient;
    return [
      _KeyedBox(
        _mailboxCacheClient.accountIdsForUser,
        _mailboxCacheClient.deleteKeysForAccount,
      ),
      _KeyedBox(
        _emailCacheClient.accountIdsForUser,
        _emailCacheClient.deleteKeysForAccount,
      ),
      _KeyedBox(
        _stateCacheClient.accountIdsForUser,
        _stateCacheClient.deleteKeysForAccount,
      ),
      _KeyedBox(
        _newEmailCacheClient.accountIdsForUser,
        _newEmailCacheClient.deleteKeysForAccount,
      ),
      _KeyedBox(
        _openedEmailCacheClient.accountIdsForUser,
        _openedEmailCacheClient.deleteKeysForAccount,
      ),
      _KeyedBox(
        _sendingEmailCacheClient.accountIdsForUser,
        _sendingEmailCacheClient.deleteKeysForAccount,
      ),
      _KeyedBox(
        _fcmCacheClient.accountIdsForUser,
        _fcmCacheClient.deleteKeysForAccount,
      ),
      if (composer != null)
        _KeyedBox(
          composer.accountIdsForUser,
          composer.deleteKeysForAccount,
        ),
    ];
  }

  @override
  Future<Set<AccountId>> storedAccountIds({
    required UserName userName,
    required AccountId personalAccountId,
  }) async {
    final rawIds = <String>{};
    for (final box in _boxes) {
      try {
        rawIds.addAll(await box.accountIds(userName.value));
      } catch (error) {
        logWarning('EndedDelegationStoreImpl::storedAccountIds: $error');
      }
    }
    rawIds.addAll(_webComposerAccountIds(userName.value));
    rawIds.addAll(await _keychainDelegatedIds(personalAccountId));
    return rawIds.map((id) => AccountId(Id(id))).toSet();
  }

  @override
  Future<StoredDelegatedAccount> describe(
    UserName userName,
    AccountId accountId,
  ) async {
    return StoredDelegatedAccount(
      accountId: accountId,
      unsentCount: await _unsentCount(userName, accountId),
      draftCount: await _draftCount(userName, accountId),
    );
  }

  @override
  Future<void> delete({
    required UserName userName,
    required AccountId personalAccountId,
    required AccountId accountId,
  }) async {
    if (accountId == personalAccountId) return;
    // Keychain first: a failed write leaves the id in the next scan, so the
    // hive rows are not removed and then forgotten.
    await _removeKeychainItem(personalAccountId, accountId);
    final emailIds = await _emailIds(userName, accountId);
    await _deleteContentFiles(userName, accountId);
    for (final box in _boxes) {
      try {
        await box.delete(accountId.asString, userName.value);
      } catch (error) {
        logWarning('EndedDelegationStoreImpl::delete: $error');
      }
    }
    await _deleteComposerSnapshots(userName, accountId);
    await _removeNotifications(userName, accountId, emailIds);
  }

  @override
  Future<void> removeDelegatedComposerSnapshots({
    required UserName userName,
    required AccountId personalAccountId,
  }) async {
    final accountIds = <String>{};
    final composerHive = _composerHiveCacheClient;
    if (composerHive != null) {
      try {
        accountIds.addAll(await composerHive.accountIdsForUser(userName.value));
      } catch (error) {
        logWarning(
          'EndedDelegationStoreImpl::removeDelegatedComposerSnapshots: $error',
        );
      }
    }
    accountIds.addAll(_webComposerAccountIds(userName.value));
    for (final rawId in accountIds) {
      final accountId = AccountId(Id(rawId));
      if (!ComposerSnapshotPolicy.removeOnLogout(
        snapshotAccountId: accountId,
        personalAccountId: personalAccountId,
        snapshotUserName: userName.value,
        signedInUserName: userName.value,
      )) {
        continue;
      }
      await _deleteComposerSnapshots(userName, accountId);
    }
  }

  Future<int> _unsentCount(UserName userName, AccountId accountId) =>
      _countKeys(() => _sendingEmailCacheClient.encodedKeys(), userName, accountId);

  Future<int> _draftCount(UserName userName, AccountId accountId) async {
    final composerHive = _composerHiveCacheClient;
    final hiveCount = composerHive == null
        ? 0
        : await _countKeys(() => composerHive.encodedKeys(), userName, accountId);
    return hiveCount + _webComposerKeys(userName, accountId).length;
  }

  Future<int> _countKeys(
    Future<List<String>> Function() readKeys,
    UserName userName,
    AccountId accountId,
  ) async {
    var count = 0;
    for (final key in await readKeys()) {
      final decoded = CacheAccountKey.tryDecode(key);
      if (decoded == null) continue;
      if (CacheAccountKey.belongsTo(
        decoded: decoded,
        accountId: accountId.asString,
        userName: userName.value,
      )) {
        count++;
      }
    }
    return count;
  }

  Future<Set<String>> _emailIds(UserName userName, AccountId accountId) async {
    final emailIds = <String>{};
    try {
      final emails = await _emailCacheManager.getAllEmail(accountId, userName);
      for (final email in emails) {
        final id = email.id?.asString;
        if (id != null && id.isNotEmpty) emailIds.add(id);
      }
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::_emailIds: list $error');
    }
    emailIds.addAll(await _contentEmailIds(
      () => _openedEmailCacheManager.getAllDetailedEmails(accountId, userName),
    ));
    emailIds.addAll(await _contentEmailIds(
      () => _newEmailCacheManager.getAllDetailedEmails(accountId, userName),
    ));
    return emailIds;
  }

  Future<Set<String>> _contentEmailIds(
    Future<List<DetailedEmailHiveCache>> Function() read,
  ) async {
    try {
      final emails = await read();
      return emails.map((email) => email.emailId).where((id) => id.isNotEmpty).toSet();
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::_contentEmailIds: $error');
      return {};
    }
  }

  Future<void> _deleteContentFiles(UserName userName, AccountId accountId) async {
    await _deleteContentPaths(
      () => _openedEmailCacheManager.getAllDetailedEmails(accountId, userName),
    );
    await _deleteContentPaths(
      () => _newEmailCacheManager.getAllDetailedEmails(accountId, userName),
    );
  }

  Future<void> _deleteContentPaths(
    Future<List<DetailedEmailHiveCache>> Function() read,
  ) async {
    late final List<DetailedEmailHiveCache> emails;
    try {
      emails = await read();
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::_deleteContentPaths: $error');
      return;
    }
    for (final email in emails) {
      final path = email.emailContentPath;
      if (path == null || path.isEmpty) continue;
      try {
        await _fileUtils.deleteFile(path);
      } catch (error) {
        logWarning('EndedDelegationStoreImpl::_deleteContentPaths: file $error');
      }
    }
  }

  Future<void> _deleteComposerSnapshots(
    UserName userName,
    AccountId accountId,
  ) async {
    final composerHive = _composerHiveCacheClient;
    if (composerHive != null) {
      try {
        await composerHive.deleteKeysForAccount(accountId.asString, userName.value);
      } catch (error) {
        logWarning('EndedDelegationStoreImpl::_deleteComposerSnapshots: $error');
      }
    }
    for (final key in _webComposerKeys(userName, accountId)) {
      html.window.sessionStorage.remove(key);
    }
  }

  List<String> _webComposerKeys(UserName userName, AccountId accountId) {
    if (!PlatformInfo.isWeb) return const [];
    return html.window.sessionStorage.keys.where((key) {
      if (!key.startsWith(_composerKeyPrefix)) return false;
      return CacheAccountKey.belongsTo(
        decoded: key,
        accountId: accountId.asString,
        userName: userName.value,
      );
    }).toList();
  }

  Set<String> _webComposerAccountIds(String userName) {
    if (!PlatformInfo.isWeb) return {};
    final accountIds = <String>{};
    for (final key in html.window.sessionStorage.keys) {
      if (!key.startsWith(_composerKeyPrefix)) continue;
      final accountId = CacheAccountKey.accountIdOf(key, userName);
      if (accountId != null) accountIds.add(accountId);
    }
    return accountIds;
  }

  Future<Set<String>> _keychainDelegatedIds(AccountId personalAccountId) async {
    try {
      final sharingSession =
          await _keychainSharingManager.getSharingSession(personalAccountId);
      return sharingSession?.delegatedAccounts
              ?.map((item) => item.accountId.asString)
              .where((id) => id.isNotEmpty)
              .toSet() ??
          {};
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::_keychainDelegatedIds: $error');
      return {};
    }
  }

  Future<void> _removeKeychainItem(
    AccountId personalAccountId,
    AccountId accountId,
  ) async {
    final sharingSession =
        await _keychainSharingManager.getSharingSession(personalAccountId);
    if (sharingSession == null) return;
    final current = sharingSession.delegatedAccounts
        ?.map((item) => item.accountId.asString)
        .toList();
    final kept = EndedDelegationCleanup.keychainIdsAfterRemoval(
      current,
      accountId.asString,
    );
    if (identical(kept, current)) return;
    if (kept == null) {
      sharingSession.delegatedAccounts = null;
    } else {
      sharingSession.delegatedAccounts = sharingSession.delegatedAccounts
          ?.where((item) => kept.contains(item.accountId.asString))
          .toList();
    }
    await _keychainSharingManager.saveSharingSession(sharingSession);
  }

  Future<void> _removeNotifications(
    UserName userName,
    AccountId accountId,
    Set<String> emailIds,
  ) async {
    if (!PlatformInfo.isMobile) return;
    try {
      await LocalNotificationManager.instance.removeMatchingNotifications(
        (payload, groupKey) =>
            notificationGroupIsThisUser(groupKey, userName.value) &&
            payloadNamesAccountOrEmail(payload, accountId.asString, emailIds),
      );
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::_removeNotifications: $error');
    }
  }
}

class _KeyedBox {
  final Future<Set<String>> Function(String userName) accountIds;
  final Future<void> Function(String accountId, String userName) delete;

  _KeyedBox(this.accountIds, this.delete);
}
