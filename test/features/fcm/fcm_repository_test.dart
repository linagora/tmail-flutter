import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/mailbox_extension.dart';
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

  group('getMailboxesNotPutNotifications_method::test', () {
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

    test('should returns mailboxes with notifications deactivated from local cache', () async {
      // Arrange
      final Mailbox mailbox1 = Mailbox(
        id: MailboxId(Id('spam-id')),
        role: PresentationMailbox.roleSpam);
      final Mailbox mailbox2 = Mailbox(
        id: MailboxId(Id('inbox-id')),
        role: PresentationMailbox.roleInbox);
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(
        accountIdFixture,
        userNameFixture
      )).thenAnswer((_) async => [mailbox1, mailbox2]);

      // Act
      final result = await fcmRepository.getMailboxesNotPutNotifications(
        sessionFixture,
        accountIdFixture);

      // Assert
      expect(mailbox1.pushNotificationDeactivated, isTrue);
      expect(mailbox2.pushNotificationDeactivated, isFalse);
      expect(result, hasLength(1));
      expect(result.first.pushNotificationDeactivated, isTrue);
    });

    test('should falls back to network source if local cache is empty', () async {
      // Arrange
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(
        accountIdFixture,
        userNameFixture
      )).thenAnswer((_) async => []);

      final Mailbox mailbox1 = Mailbox(
        id: MailboxId(Id('spam-id')),
        role: PresentationMailbox.roleSpam);
      final mailboxResponse = JmapMailboxResponse(mailboxes: [mailbox1]);
      when(mailboxDataSource.getAllMailbox(
        sessionFixture,
        accountIdFixture
      )).thenAnswer((_) async => mailboxResponse);

      // Act
      final result = await fcmRepository.getMailboxesNotPutNotifications(
        sessionFixture,
        accountIdFixture);

      // Assert
      expect(mailbox1.pushNotificationDeactivated, isTrue);
      expect(result, hasLength(1));
      expect(result.first.pushNotificationDeactivated, isTrue);
    });

    test('should returns empty list if no mailboxes have notifications deactivated', () async {
      // Arrange
      final Mailbox mailbox1 = Mailbox(
        id: MailboxId(Id('inbox-id')),
        role: PresentationMailbox.roleInbox);
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(
        accountIdFixture,
        userNameFixture
      )).thenAnswer((_) async => [mailbox1]);
      final mailboxResponse = JmapMailboxResponse(mailboxes: [mailbox1]);
      when(mailboxDataSource.getAllMailbox(
        sessionFixture,
        accountIdFixture
      )).thenAnswer((_) async => mailboxResponse);

      // Act
      final result = await fcmRepository.getMailboxesNotPutNotifications(
        sessionFixture,
        accountIdFixture);

      // Assert
      expect(mailbox1.pushNotificationDeactivated, isFalse);
      expect(result, isEmpty);
    });
  });
}