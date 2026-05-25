import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';

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

  group('getMailboxesForNotification:', () {
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

    test('returns excluded mailboxes from cache when inbox is present', () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(
        accountIdFixture,
        userNameFixture,
      )).thenAnswer((_) async => [spamMailbox, inboxMailbox]);

      final result = await fcmRepository.getMailboxesForNotification(
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

      final result = await fcmRepository.getMailboxesForNotification(
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

      final result = await fcmRepository.getMailboxesForNotification(
        sessionFixture,
        accountIdFixture,
      );

      expect(result, hasLength(1));
      expect(result.first.pushNotificationDeactivated, isTrue);
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

      final result = await fcmRepository.getMailboxesForNotification(
        sessionFixture,
        accountIdFixture,
      );

      expect(result, hasLength(1));
      expect(result.first.pushNotificationDeactivated, isTrue);
    });
  });
}
