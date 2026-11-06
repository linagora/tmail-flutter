import 'package:core/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/fcm_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/new_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/sending_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_account_key.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/ended_delegation_store_impl.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/cleanup_ended_delegations_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/cleanup_ended_delegations_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_email_hive_cache.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_session.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  group('EndedDelegationStoreImpl.delete', () {
    test(
      'a failed box delete is left out of the deleted accounts and the lost count',
      () async {
        final rig = _Rig();
        final session = DelegationFixtures.session();
        final gone = DelegationFixtures.unknownAccountId;
        final user = session.username.value;
        rig.mailbox.memory.items[TupleKey('box', gone.id.value, user).encodeKey] = null;
        rig.sending.memory.items[TupleKey('out', gone.id.value, user).encodeKey] = null;
        rig.mailbox.memory.deleteError = StateError(gone.id.value);

        expect((await rig.store.describe(session.username, gone)).lostCount, 1);
        final cleaned =
            (await CleanupEndedDelegationsInteractor(rig.store).execute(
                  session: session,
                  fromCache: false,
                )).getOrElse(() => throw StateError('failure'))
                as CleanupEndedDelegationsSuccess;

        expect(cleaned.deletedAccountIds, isEmpty);
        expect(cleaned.lostCount, 0);
        await expectLater(
          rig.store.delete(
            userName: session.username,
            personalAccountId: session.accountId,
            accountId: gone,
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              'EndedDelegationStoreImpl::delete: 1 failed',
            ),
          ),
        );
      },
    );

    test(
      'a username that only continues this one is neither read nor deleted',
      () async {
        final rig = _Rig();
        const user = 'user';
        const account = 'acc';
        final mine = TupleKey('email-1', account, user).encodeKey;
        final other = TupleKey('email-2', account, 'user2').encodeKey;
        rig.opened.memory.items[mine] = DetailedEmailHiveCache(
          emailId: 'email-1',
          timeSaved: DateTime.utc(2026),
          emailContentPath: 'opened-body',
        );
        rig.opened.memory.items[other] = DetailedEmailHiveCache(
          emailId: 'email-2',
          timeSaved: DateTime.utc(2026),
          emailContentPath: 'other-body',
        );

        await rig.store.delete(
          userName: UserName(user),
          personalAccountId: AccountId(Id('personal')),
          accountId: AccountId(Id(account)),
        );

        expect(rig.files.deleted, ['opened-body']);
        expect(rig.opened.memory.items.containsKey(mine), isFalse);
        expect(rig.opened.memory.items.containsKey(other), isTrue);
      },
    );

    test(
      'a list row whose username only continues this one is not named',
      () async {
        final rig = _Rig();
        const user = 'user';
        const account = 'acc';
        rig.email.memory.items[TupleKey('email-1', account, user).encodeKey] =
            EmailCache('email-1');
        rig.email.memory.items[
                TupleKey('email-2', account, 'user2').encodeKey] =
            EmailCache('email-2');

        final ids = await rig.store.notificationEmailIds(
          UserName(user),
          AccountId(Id(account)),
        );

        expect(ids, {'email-1'});
      },
    );

    test(
      'keeps content rows when a file delete fails and clears them on the retry',
      () async {
        final rig = _Rig();
        const user = 'user';
        const account = 'acc';
        final openedKey = TupleKey('email-1', account, user).encodeKey;
        final newKey = TupleKey('email-2', account, user).encodeKey;
        rig.opened.memory.items[openedKey] = DetailedEmailHiveCache(
          emailId: 'email-1',
          timeSaved: DateTime.utc(2026),
          emailContentPath: 'opened-body',
        );
        rig.fresh.memory.items[newKey] = DetailedEmailHiveCache(
          emailId: 'email-2',
          timeSaved: DateTime.utc(2026),
          emailContentPath: 'new-body',
        );
        for (final box in rig.otherBoxes) {
          box.items[TupleKey('item', account, user).encodeKey] = null;
        }
        rig.files.fail = true;

        await expectLater(
          rig.store.delete(
            userName: UserName(user),
            personalAccountId: AccountId(Id('personal')),
            accountId: AccountId(Id(account)),
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              'EndedDelegationStoreImpl::delete: 2 failed',
            ),
          ),
        );
        expect(rig.files.deleted, isEmpty);
        expect(rig.opened.memory.items.containsKey(openedKey), isTrue);
        expect(rig.fresh.memory.items.containsKey(newKey), isTrue);
        for (final box in rig.otherBoxes) {
          expect(box.items, isEmpty);
        }

        rig.files.fail = false;
        await rig.store.delete(
          userName: UserName(user),
          personalAccountId: AccountId(Id('personal')),
          accountId: AccountId(Id(account)),
        );

        expect(rig.files.deleted, ['opened-body', 'new-body']);
        expect(rig.opened.memory.items, isEmpty);
        expect(rig.fresh.memory.items, isEmpty);
      },
    );

    test('keeps content rows when reading them fails', () async {
      final rig = _Rig();
      const user = 'user';
      const account = 'acc';
      final openedKey = TupleKey('email-1', account, user).encodeKey;
      final newKey = TupleKey('email-2', account, user).encodeKey;
      rig.opened.memory.items[openedKey] = DetailedEmailHiveCache(
        emailId: 'email-1',
        timeSaved: DateTime.utc(2026),
        emailContentPath: 'opened-body',
      );
      rig.fresh.memory.items[newKey] = DetailedEmailHiveCache(
        emailId: 'email-2',
        timeSaved: DateTime.utc(2026),
        emailContentPath: 'new-body',
      );
      rig.opened.memory.readError = StateError('read');
      rig.mailbox.memory.items[TupleKey('box', account, user).encodeKey] = null;

      await expectLater(
        rig.store.delete(
          userName: UserName(user),
          personalAccountId: AccountId(Id('personal')),
          accountId: AccountId(Id(account)),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'EndedDelegationStoreImpl::delete: 1 failed',
          ),
        ),
      );

      expect(rig.opened.memory.items.containsKey(openedKey), isTrue);
      expect(rig.fresh.memory.items.containsKey(newKey), isTrue);
      expect(rig.mailbox.memory.items, isEmpty);
      expect(rig.files.deleted, ['new-body']);
    });
  });
}

class _Rig {
  _Rig()
    : mailbox = _MailboxBox(_Memory()),
      email = _EmailBox(_Memory()),
      state = _StateBox(_Memory()),
      opened = _OpenedBox(_Memory()),
      fresh = _NewBox(_Memory()),
      sending = _SendingBox(_Memory()),
      fcm = _FcmBox(_Memory()),
      files = _Files() {
    store = EndedDelegationStoreImpl(
      mailboxCacheClient: mailbox,
      emailCacheClient: email,
      stateCacheClient: state,
      newEmailCacheClient: fresh,
      openedEmailCacheClient: opened,
      sendingEmailCacheClient: sending,
      fcmCacheClient: fcm,
      keychainSharingManager: _Keychain(),
      fileUtils: files,
    );
  }

  final _MailboxBox mailbox;
  final _EmailBox email;
  final _StateBox state;
  final _OpenedBox opened;
  final _NewBox fresh;
  final _SendingBox sending;
  final _FcmBox fcm;
  final _Files files;
  late final EndedDelegationStoreImpl store;

  List<_Memory> get otherBoxes => [
    mailbox.memory,
    email.memory,
    state.memory,
    sending.memory,
    fcm.memory,
  ];
}

class _Memory {
  final items = <String, Object?>{};
  Object? deleteError;
  Object? readError;

  Future<Set<String>> accountIds(String userName) async {
    final ids = <String>{};
    for (final key in items.keys) {
      final decoded = CacheAccountKey.tryDecode(key);
      if (decoded == null) continue;
      final accountId = CacheAccountKey.accountIdOf(decoded, userName);
      if (accountId != null) ids.add(accountId);
    }
    return ids;
  }

  Future<void> delete(String accountId, String userName) async {
    if (deleteError != null) throw deleteError!;
    final drop = <String>[];
    for (final key in items.keys) {
      final decoded = CacheAccountKey.tryDecode(key);
      if (decoded == null) continue;
      if (CacheAccountKey.belongsTo(
        decoded: decoded,
        accountId: accountId,
        userName: userName,
      )) {
        drop.add(key);
      }
    }
    for (final key in drop) {
      items.remove(key);
    }
  }
}

mixin _KeyedMemory<T> on HiveCacheClient<T> {
  _Memory get memory;

  @override
  Future<Set<String>> accountIdsForUser(String userName) =>
      memory.accountIds(userName);

  @override
  Future<void> deleteKeysForAccount(String accountId, String userName) =>
      memory.delete(accountId, userName);

  @override
  Future<List<String>> encodedKeys({bool isolated = true}) async =>
      memory.items.keys.toList();

  @override
  Future<Map<String, T>> getMapItems({bool isolated = true}) async {
    final error = memory.readError;
    if (error != null) throw error;
    return {
      for (final entry in memory.items.entries) entry.key: entry.value as T,
    };
  }
}

class _MailboxBox extends MailboxCacheClient with _KeyedMemory<MailboxCache> {
  _MailboxBox(this.memory);

  @override
  final _Memory memory;
}

class _EmailBox extends EmailCacheClient with _KeyedMemory<EmailCache> {
  _EmailBox(this.memory);

  @override
  final _Memory memory;
}

class _StateBox extends StateCacheClient with _KeyedMemory<StateCache> {
  _StateBox(this.memory);

  @override
  final _Memory memory;
}

class _OpenedBox extends OpenedEmailHiveCacheClient
    with _KeyedMemory<DetailedEmailHiveCache> {
  _OpenedBox(this.memory);

  @override
  final _Memory memory;
}

class _NewBox extends NewEmailHiveCacheClient
    with _KeyedMemory<DetailedEmailHiveCache> {
  _NewBox(this.memory);

  @override
  final _Memory memory;
}

class _SendingBox extends SendingEmailHiveCacheClient
    with _KeyedMemory<SendingEmailHiveCache> {
  _SendingBox(this.memory);

  @override
  final _Memory memory;
}

class _FcmBox extends FcmCacheClient with _KeyedMemory<String> {
  _FcmBox(this.memory);

  @override
  final _Memory memory;
}

class _Files extends Fake implements FileUtils {
  final deleted = <String>[];
  var fail = false;

  @override
  Future<void> deleteFile(String filePath) async {
    if (fail) throw StateError('disk');
    deleted.add(filePath);
  }
}

class _Keychain extends Fake implements KeychainSharingManager {
  @override
  Future<KeychainSharingSession?> getSharingSession(
    AccountId accountId,
  ) async => null;
}
