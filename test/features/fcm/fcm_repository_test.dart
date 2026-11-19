import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:fcm/model/type_name.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_delegated_account.dart';
import 'package:tmail_ui_user/features/push_notification/domain/model/delegated_notification_baseline.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource/fcm_datasource.dart';
import 'package:tmail_ui_user/features/push_notification/data/datasource_impl/cache_fcm_datasource_impl.dart';
import 'package:tmail_ui_user/features/push_notification/data/repository/fcm_repository_impl.dart';
import 'package:tmail_ui_user/features/push_notification/domain/exceptions/fcm_exception.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';

import '../../fixtures/delegation_fixtures.dart';
import '../../fixtures/session_fixtures.dart';

import 'fcm_repository_test.mocks.dart';

@GenerateMocks([
  FCMDatasource,
  CacheFCMDatasourceImpl,
  MailboxDataSource,
  MailboxCacheDataSourceImpl,
  ThreadDataSource
])
void main() {
  late FCMDatasource fcmDatasource;
  late CacheFCMDatasourceImpl cacheFCMDatasourceImpl;
  late MailboxDataSource mailboxDataSource;
  late MailboxCacheDataSourceImpl mailboxCacheDataSourceImpl;
  late ThreadDataSource threadDataSource;
  late FCMRepository fcmRepository;

  final sessionFixture = SessionFixtures.aliceSession;
  final accountIdFixture = SessionFixtures.aliceSession.accountId;
  final userNameFixture = SessionFixtures.aliceSession.username;

  final inboxMailbox = Mailbox(
    id: MailboxId(Id('inbox-id')),
    role: PresentationMailbox.roleInbox,
  );
  final spamMailbox = Mailbox(
    id: MailboxId(Id('spam-id')),
    role: PresentationMailbox.roleSpam,
  );

  setUp(() {
    fcmDatasource = MockFCMDatasource();
    cacheFCMDatasourceImpl = MockCacheFCMDatasourceImpl();
    mailboxDataSource = MockMailboxDataSource();
    mailboxCacheDataSourceImpl = MockMailboxCacheDataSourceImpl();
    threadDataSource = MockThreadDataSource();
    fcmRepository = FCMRepositoryImpl(
      {
        DataSourceType.network: fcmDatasource,
        DataSourceType.local: cacheFCMDatasourceImpl
      },
      threadDataSource,
      {
        DataSourceType.network: mailboxDataSource,
        DataSourceType.local: mailboxCacheDataSourceImpl
      },
    );
  });

  group('getExcludedMailboxesForNotification:', () {
    test('returns excluded mailboxes from cache when inbox is present', () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(
        accountIdFixture,
        userNameFixture,
      )).thenAnswer((_) async => [spamMailbox, inboxMailbox]);

      final result = await fcmRepository.getExcludedMailboxesForNotification(
        sessionFixture,
        accountIdFixture,
      );

      expect(result, hasLength(1));
      expect(result.first.pushNotificationDeactivated, isTrue);
      verifyNever(mailboxDataSource.getAllMailbox(sessionFixture, accountIdFixture));
    });

    test('returns empty excluded list when cache has only inbox', () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(
        accountIdFixture,
        userNameFixture,
      )).thenAnswer((_) async => [inboxMailbox]);

      final result = await fcmRepository.getExcludedMailboxesForNotification(
        sessionFixture,
        accountIdFixture,
      );

      expect(result, isEmpty);
      verifyNever(mailboxDataSource.getAllMailbox(sessionFixture, accountIdFixture));
    });

    test('falls back to network when inbox is not in cache', () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(
        accountIdFixture,
        userNameFixture,
      )).thenAnswer((_) async => []);

      when(mailboxDataSource.getAllMailbox(
        sessionFixture,
        accountIdFixture,
      )).thenAnswer((_) async => JmapMailboxResponse(mailboxes: [spamMailbox]));

      final result = await fcmRepository.getExcludedMailboxesForNotification(
        sessionFixture,
        accountIdFixture,
      );

      expect(result, hasLength(1));
      expect(result.first.pushNotificationDeactivated, isTrue);
      verify(mailboxDataSource.getAllMailbox(sessionFixture, accountIdFixture)).called(1);
    });

    test('falls back to network and returns excluded mailboxes when cache has no inbox', () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(
        accountIdFixture,
        userNameFixture,
      )).thenAnswer((_) async => [spamMailbox]);

      when(mailboxDataSource.getAllMailbox(
        sessionFixture,
        accountIdFixture,
      )).thenAnswer((_) async => JmapMailboxResponse(
        mailboxes: [spamMailbox, inboxMailbox],
      ));

      final result = await fcmRepository.getExcludedMailboxesForNotification(
        sessionFixture,
        accountIdFixture,
      );

      expect(result, hasLength(1));
      expect(result.first.pushNotificationDeactivated, isTrue);
      verify(mailboxDataSource.getAllMailbox(sessionFixture, accountIdFixture)).called(1);
    });
  });

  group('storeDelegatedNotificationBaselines:', () {
    final bobAccountId = AccountId(Id('bob-account-id'));
    final bobState = jmap.State('bob-state');
    final baseline = DelegatedNotificationBaseline(
      accountId: bobAccountId,
      state: bobState,
      ownerName: 'bob@domain.tld',
    );

    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('on iOS writes the keychain items of the personal session with the blocked mailboxes', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(bobAccountId, userNameFixture))
          .thenAnswer((_) async => [spamMailbox, inboxMailbox]);

      await fcmRepository.storeDelegatedNotificationBaselines(sessionFixture, [baseline]);

      verify(cacheFCMDatasourceImpl.storeDelegatedAccountsInKeychain(accountIdFixture, [
        KeychainDelegatedAccount(
          accountId: bobAccountId,
          emailDeliveryState: 'bob-state',
          mailboxIdsBlockNotification: [spamMailbox.id!],
          ownerName: 'bob@domain.tld',
        ),
      ])).called(1);
      verifyNoMoreInteractions(cacheFCMDatasourceImpl);
    });

    test('on iOS keeps the item without a block list when the mailboxes cannot be read', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(bobAccountId, userNameFixture))
          .thenThrow(Exception('cache closed'));
      when(mailboxDataSource.getAllMailbox(sessionFixture, bobAccountId))
          .thenThrow(Exception('offline'));

      await fcmRepository.storeDelegatedNotificationBaselines(sessionFixture, [baseline]);

      verify(cacheFCMDatasourceImpl.storeDelegatedAccountsInKeychain(accountIdFixture, [
        KeychainDelegatedAccount(
          accountId: bobAccountId,
          emailDeliveryState: 'bob-state',
          ownerName: 'bob@domain.tld',
        ),
      ])).called(1);
    });

    test('on iOS clears the keychain items when no mailbox is notified', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await fcmRepository.storeDelegatedNotificationBaselines(sessionFixture, []);

      verify(cacheFCMDatasourceImpl.storeDelegatedAccountsInKeychain(accountIdFixture, [])).called(1);
    });

    test('on Android stores the state to refresh of each delegated mailbox', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await fcmRepository.storeDelegatedNotificationBaselines(sessionFixture, [baseline]);

      verify(cacheFCMDatasourceImpl.storeStateToRefresh(
        bobAccountId,
        userNameFixture,
        TypeName.emailDelivery,
        bobState,
      )).called(1);
      verifyNoMoreInteractions(cacheFCMDatasourceImpl);
    });

    test('on iOS sends the item of a kept cursor without a state', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(bobAccountId, userNameFixture))
          .thenAnswer((_) async => [inboxMailbox]);

      await fcmRepository.storeDelegatedNotificationBaselines(sessionFixture, [
        DelegatedNotificationBaseline(accountId: bobAccountId, ownerName: 'bob@domain.tld'),
      ]);

      verify(cacheFCMDatasourceImpl.storeDelegatedAccountsInKeychain(accountIdFixture, [
        KeychainDelegatedAccount(
          accountId: bobAccountId,
          mailboxIdsBlockNotification: const [],
          ownerName: 'bob@domain.tld',
        ),
      ])).called(1);
    });

    test('on Android keeps a cursor without a state and drops the cursor of a mailbox no longer notified', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final session = DelegationFixtures.session();

      await fcmRepository.storeDelegatedNotificationBaselines(session, [
        DelegatedNotificationBaseline(
          accountId: DelegationFixtures.bobAccountId,
          ownerName: DelegationFixtures.bobAddress,
        ),
      ]);

      verify(cacheFCMDatasourceImpl.deleteStateToRefresh(
        DelegationFixtures.carolAccountId,
        session.username,
        TypeName.emailDelivery,
      )).called(1);
      verifyNoMoreInteractions(cacheFCMDatasourceImpl);
    });
  });

  group('getDelegatedAccountIdsWithNotificationCursor:', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('on iOS returns the keychain items that hold a cursor', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      when(cacheFCMDatasourceImpl.getDelegatedAccountsInKeychain(accountIdFixture)).thenAnswer((_) async => [
            KeychainDelegatedAccount(accountId: DelegationFixtures.bobAccountId, emailDeliveryState: 'bob-state'),
            KeychainDelegatedAccount(accountId: DelegationFixtures.carolAccountId),
          ]);

      expect(
        await fcmRepository.getDelegatedAccountIdsWithNotificationCursor(sessionFixture),
        {DelegationFixtures.bobAccountId},
      );
    });

    test('on Android returns the delegated mailboxes with a stored state', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final session = DelegationFixtures.session();
      when(cacheFCMDatasourceImpl.getStateToRefresh(
        DelegationFixtures.bobAccountId,
        session.username,
        TypeName.emailDelivery,
      )).thenAnswer((_) async => jmap.State('bob-state'));
      when(cacheFCMDatasourceImpl.getStateToRefresh(
        DelegationFixtures.carolAccountId,
        session.username,
        TypeName.emailDelivery,
      )).thenThrow(const NotFoundEmailDeliveryStateException());

      expect(
        await fcmRepository.getDelegatedAccountIdsWithNotificationCursor(session),
        {DelegationFixtures.bobAccountId},
      );
    });

    test('on Android SHOULD NOT treat an unreadable cache as a missing cursor', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final session = DelegationFixtures.session();
      when(cacheFCMDatasourceImpl.getStateToRefresh(
        DelegationFixtures.bobAccountId,
        session.username,
        TypeName.emailDelivery,
      )).thenThrow(Exception('cache closed'));

      await expectLater(
        fcmRepository.getDelegatedAccountIdsWithNotificationCursor(session),
        throwsA(isA<Exception>()),
      );
    });
  });
}
