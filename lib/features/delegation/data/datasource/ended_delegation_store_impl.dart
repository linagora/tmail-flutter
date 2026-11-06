import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:meta/meta.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/new_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/sending_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_account_key.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/composer_snapshot_policy.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_cleanup.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/ended_delegation_notification.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/ended_delegation_store.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';
import 'package:universal_html/html.dart' as html;

typedef WebSessionStorageKeys = Iterable<String> Function();
typedef WebSessionStorageRemove = void Function(String key);
typedef _SessionStorageAction = void Function();

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
  final KeychainSharingManager _keychainSharingManager;
  final FileUtils _fileUtils;
  final WebSessionStorageKeys _sessionStorageKeys;
  final WebSessionStorageRemove _sessionStorageRemove;

  EndedDelegationStoreImpl({
    required MailboxCacheClient mailboxCacheClient,
    required EmailCacheClient emailCacheClient,
    required StateCacheClient stateCacheClient,
    required NewEmailHiveCacheClient newEmailCacheClient,
    required OpenedEmailHiveCacheClient openedEmailCacheClient,
    required SendingEmailHiveCacheClient sendingEmailCacheClient,
    required FcmCacheClient fcmCacheClient,
    required KeychainSharingManager keychainSharingManager,
    required FileUtils fileUtils,
    ComposerHiveCacheClient? composerHiveCacheClient,
    WebSessionStorageKeys? sessionStorageKeys,
    WebSessionStorageRemove? sessionStorageRemove,
  })  : _mailboxCacheClient = mailboxCacheClient,
        _emailCacheClient = emailCacheClient,
        _stateCacheClient = stateCacheClient,
        _newEmailCacheClient = newEmailCacheClient,
        _openedEmailCacheClient = openedEmailCacheClient,
        _sendingEmailCacheClient = sendingEmailCacheClient,
        _fcmCacheClient = fcmCacheClient,
        _composerHiveCacheClient = composerHiveCacheClient,
        _keychainSharingManager = keychainSharingManager,
        _fileUtils = fileUtils,
        _sessionStorageKeys = sessionStorageKeys ?? _windowSessionStorageKeys,
        _sessionStorageRemove =
            sessionStorageRemove ?? _windowSessionStorageRemove;

  static Iterable<String> _windowSessionStorageKeys() =>
      html.window.sessionStorage.keys;

  static void _windowSessionStorageRemove(String key) {
    html.window.sessionStorage.remove(key);
  }

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
        keepsContentPaths: true,
      ),
      _KeyedBox(
        _openedEmailCacheClient.accountIdsForUser,
        _openedEmailCacheClient.deleteKeysForAccount,
        keepsContentPaths: true,
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
    final contentFailures = await _deleteContentFiles(userName, accountId);
    final boxFailures = await _deleteAccountBoxes(
      accountId.asString,
      userName.value,
      keepContentRows: contentFailures > 0,
    );
    await _deleteComposerSnapshots(userName, accountId);
    await _removeNotifications(userName, emailIds);
    final failedSteps = contentFailures + boxFailures;
    if (failedSteps > 0) {
      throw StateError('EndedDelegationStoreImpl::delete: $failedSteps failed');
    }
  }

  /// Opened and new rows stay when a file step failed so the next scan can retry.
  Future<int> _deleteAccountBoxes(
    String accountId,
    String userName, {
    required bool keepContentRows,
  }) async {
    var failed = 0;
    for (final box in _boxes) {
      if (keepContentRows && box.keepsContentPaths) continue;
      try {
        await box.delete(accountId, userName);
      } catch (error) {
        failed++;
        logWarning('EndedDelegationStoreImpl::delete: ${error.runtimeType}');
      }
    }
    return failed;
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

  /// Ids named when this account's notifications are removed.
  @visibleForTesting
  Future<Set<String>> notificationEmailIds(
    UserName userName,
    AccountId accountId,
  ) => _emailIds(userName, accountId);

  Future<Set<String>> _emailIds(UserName userName, AccountId accountId) async {
    final emailIds = <String>{};
    try {
      final rows = await _rowsOf(
        _emailCacheClient,
        accountId.asString,
        userName.value,
      );
      emailIds.addAll(rows.map((row) => row.id).where((id) => id.isNotEmpty));
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::_emailIds: list ${error.runtimeType}');
    }
    emailIds.addAll(await _contentEmailIds(
      _openedEmailCacheClient,
      userName,
      accountId,
    ));
    emailIds.addAll(await _contentEmailIds(
      _newEmailCacheClient,
      userName,
      accountId,
    ));
    return emailIds;
  }

  Future<Set<String>> _contentEmailIds(
    HiveCacheClient<DetailedEmailHiveCache> client,
    UserName userName,
    AccountId accountId,
  ) async {
    try {
      final emails = await _rowsOf(client, accountId.asString, userName.value);
      return emails.map((email) => email.emailId).where((id) => id.isNotEmpty).toSet();
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::_contentEmailIds: ${error.runtimeType}');
      return {};
    }
  }

  Future<int> _deleteContentFiles(UserName userName, AccountId accountId) async {
    var failed = 0;
    final rows = <DetailedEmailHiveCache>[];
    for (final client in [_openedEmailCacheClient, _newEmailCacheClient]) {
      try {
        rows.addAll(await _rowsOf(client, accountId.asString, userName.value));
      } catch (error) {
        failed++;
        logWarning('EndedDelegationStoreImpl::_deleteContentFiles: ${error.runtimeType}');
      }
    }
    for (final email in rows) {
      final path = email.emailContentPath;
      if (path == null || path.isEmpty) continue;
      try {
        await _fileUtils.deleteFile(path);
      } catch (error) {
        failed++;
        logWarning(
          'EndedDelegationStoreImpl::_deleteContentFiles: file ${error.runtimeType}',
        );
      }
    }
    return failed;
  }

  Future<List<T>> _rowsOf<T>(
    HiveCacheClient<T> client,
    String accountId,
    String userName,
  ) async {
    final items = await client.getMapItems();
    final rows = <T>[];
    for (final entry in items.entries) {
      final decoded = CacheAccountKey.tryDecode(entry.key);
      if (decoded == null) continue;
      if (!CacheAccountKey.belongsTo(
        decoded: decoded,
        accountId: accountId,
        userName: userName,
      )) {
        continue;
      }
      rows.add(entry.value);
    }
    return rows;
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
      _withSessionStorage(
        '_deleteComposerSnapshots',
        () => _sessionStorageRemove(key),
      );
    }
  }

  // Browsers throw SecurityError when site storage is blocked.
  void _withSessionStorage(String method, _SessionStorageAction action) {
    try {
      action();
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::$method: $error');
    }
  }

  List<String> _webComposerKeys(UserName userName, AccountId accountId) {
    if (!PlatformInfo.isWeb) return const [];
    final matched = <String>[];
    _withSessionStorage('_webComposerKeys', () {
      final found = _sessionStorageKeys().where((key) {
        if (!key.startsWith(_composerKeyPrefix)) return false;
        return CacheAccountKey.belongsTo(
          decoded: key,
          accountId: accountId.asString,
          userName: userName.value,
        );
      }).toList();
      matched.addAll(found);
    });
    return matched;
  }

  Set<String> _webComposerAccountIds(String userName) {
    if (!PlatformInfo.isWeb) return {};
    final accountIds = <String>{};
    _withSessionStorage('_webComposerAccountIds', () {
      final found = <String>{};
      for (final key in _sessionStorageKeys()) {
        if (!key.startsWith(_composerKeyPrefix)) continue;
        final accountId = CacheAccountKey.accountIdOf(key, userName);
        if (accountId != null) found.add(accountId);
      }
      accountIds.addAll(found);
    });
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
    Set<String> emailIds,
  ) async {
    if (!PlatformInfo.isMobile) return;
    try {
      await LocalNotificationManager.instance.removeMatchingNotifications(
        (payload, groupKey) =>
            notificationGroupIsThisUser(groupKey, userName.value) &&
            payloadNamesEmail(payload, emailIds),
      );
    } catch (error) {
      logWarning('EndedDelegationStoreImpl::_removeNotifications: $error');
    }
  }
}

class _KeyedBox {
  final Future<Set<String>> Function(String userName) accountIds;
  final Future<void> Function(String accountId, String userName) delete;
  final bool keepsContentPaths;

  _KeyedBox(
    this.accountIds,
    this.delete, {
    this.keepsContentPaths = false,
  });
}
