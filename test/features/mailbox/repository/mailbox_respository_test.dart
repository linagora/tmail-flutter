import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource_impl/mailbox_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/mailbox/data/repository/mailbox_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/cache_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

import '../../../fixtures/mailbox_fixtures.dart';
import '../../../fixtures/session_fixtures.dart';
import '../../../fixtures/state_fixtures.dart';
import 'mailbox_respository_test.mocks.dart';

@GenerateMocks([
  MailboxDataSource,
  MailboxCacheDataSourceImpl,
  StateDataSource
])
void main() {
  late MailboxDataSource mailboxDataSource;
  late MailboxCacheDataSourceImpl mailboxCacheDataSourceImpl;
  late StateDataSource stateDataSource;
  late MailboxRepository mailboxRepository;

  final sessionFixture = SessionFixtures.aliceSession;
  final accountIdFixture = SessionFixtures.aliceSession.personalAccount.accountId;
  final userNameFixture = SessionFixtures.aliceSession.username;

  group('[getAllMailbox] method test', () {
    setUp(() {
      mailboxDataSource = MockMailboxDataSource();
      mailboxCacheDataSourceImpl = MockMailboxCacheDataSourceImpl();
      stateDataSource = MockStateDataSource();
      mailboxRepository = MailboxRepositoryImpl(
        {
          DataSourceType.network: mailboxDataSource,
          DataSourceType.local: mailboxCacheDataSourceImpl
        },
        stateDataSource);
    });

    test(
        'getAllMailbox SHOULD only return CacheMailboxResponse \n'
        'WHEN `getAllMailboxCache` has data \n'
        'AND getAllMailbox from JMAP throws NotFoundMailboxException',
    () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(accountIdFixture, userNameFixture))
        .thenAnswer((_) async => [
          MailboxFixtures.mailboxA,
          MailboxFixtures.mailboxB,
          MailboxFixtures.mailboxC,
          MailboxFixtures.mailboxD,
        ]);

      when(stateDataSource.getState(accountIdFixture, userNameFixture, StateType.mailbox))
        .thenAnswer((_) async => StateFixtures.currentMailboxState);

      when(mailboxDataSource.getAllMailbox(sessionFixture, accountIdFixture))
        .thenThrow(NotFoundMailboxException());

      final streamMailboxResponses = mailboxRepository.getAllMailbox(sessionFixture, accountIdFixture);

      await expectLater(
        streamMailboxResponses,
        emitsInOrder([
          CacheMailboxResponse(
            mailboxes: [
              MailboxFixtures.mailboxA,
              MailboxFixtures.mailboxB,
              MailboxFixtures.mailboxC,
              MailboxFixtures.mailboxD,
            ],
            state: StateFixtures.currentMailboxState
          ),
          emitsError(isA<NotFoundMailboxException>())
        ])
      );
    });

    test(
        'getAllMailbox SHOULD return [CacheMailboxResponse, JmapMailboxResponse] \n'
        'WHEN getAllMailbox from JMAP has JmapMailboxResponse with `list` property is not empty',
    () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(accountIdFixture, userNameFixture))
        .thenAnswer((_) async => [
          MailboxFixtures.mailboxA,
          MailboxFixtures.mailboxB,
          MailboxFixtures.mailboxC,
          MailboxFixtures.mailboxD,
        ]);

      when(stateDataSource.getState(accountIdFixture, userNameFixture, StateType.mailbox))
        .thenAnswer((_) async => StateFixtures.currentMailboxState);

      when(mailboxDataSource.getAllMailbox(sessionFixture, accountIdFixture))
        .thenAnswer((_) async => JmapMailboxResponse(
          mailboxes: [
            MailboxFixtures.mailboxA,
            MailboxFixtures.mailboxB,
            MailboxFixtures.mailboxC,
            MailboxFixtures.mailboxD,
          ],
          state: StateFixtures.currentMailboxState
        ));

      final streamMailboxResponses = mailboxRepository.getAllMailbox(sessionFixture, accountIdFixture);

      final listMailboxResponse = await streamMailboxResponses.toList();

      expect(listMailboxResponse.length, 2);
      expect(
        listMailboxResponse,
        containsAllInOrder([
          CacheMailboxResponse(
            mailboxes: [
              MailboxFixtures.mailboxA,
              MailboxFixtures.mailboxB,
              MailboxFixtures.mailboxC,
              MailboxFixtures.mailboxD,
            ],
            state: StateFixtures.currentMailboxState
          ),
          JmapMailboxResponse(
            mailboxes: [
              MailboxFixtures.mailboxA,
              MailboxFixtures.mailboxB,
              MailboxFixtures.mailboxC,
              MailboxFixtures.mailboxD,
            ],
            state: StateFixtures.currentMailboxState
          )
        ])
      );
    });

    test(
        'getAllMailbox SHOULD only return JmapMailboxResponse \n'
        'WHEN `getAllMailboxCache` throw an Exception \n'
        'AND getAllMailbox from JMAP has JmapMailboxResponse with `list` property is not empty',
    () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(accountIdFixture, userNameFixture))
        .thenThrow(Exception('Not Found Mailbox Cache'));

      when(stateDataSource.getState(accountIdFixture, userNameFixture, StateType.mailbox))
        .thenAnswer((_) async => null);

      when(mailboxDataSource.getAllMailbox(sessionFixture, accountIdFixture))
        .thenAnswer((_) async => JmapMailboxResponse(
          mailboxes: [
            MailboxFixtures.mailboxA,
            MailboxFixtures.mailboxB,
            MailboxFixtures.mailboxC,
            MailboxFixtures.mailboxD,
          ],
          state: StateFixtures.currentMailboxState
        ));

      final streamMailboxResponses = mailboxRepository.getAllMailbox(sessionFixture, accountIdFixture);

      final listMailboxResponse = await streamMailboxResponses.toList();

      expect(listMailboxResponse.length, 1);
      expect(
        listMailboxResponse,
        containsAllInOrder([
          JmapMailboxResponse(
            mailboxes: [
              MailboxFixtures.mailboxA,
              MailboxFixtures.mailboxB,
              MailboxFixtures.mailboxC,
              MailboxFixtures.mailboxD,
            ],
            state: StateFixtures.currentMailboxState
          )
        ])
      );
    });

    test(
        'getAllMailbox SHOULD return latest list mailbox is [MailboxA, MailboxB, MailboxB, MailboxC, MailboxD] \n'
        'WHEN `getAllMailboxCache` has [MailboxA, MailboxB] \n'
        'AND getAllMailbox from JMAP has JmapMailboxResponse with `list` property is [MailboxA, MailboxB, MailboxC, MailboxD]',
    () async {
      when(mailboxCacheDataSourceImpl.getAllMailboxCache(accountIdFixture, userNameFixture))
        .thenAnswer((_) async => [
          MailboxFixtures.mailboxA,
          MailboxFixtures.mailboxB,
        ]);

      when(stateDataSource.getState(accountIdFixture, userNameFixture, StateType.mailbox))
        .thenAnswer((_) async => StateFixtures.currentMailboxState);

      when(mailboxDataSource.getAllMailbox(sessionFixture, accountIdFixture))
        .thenAnswer((_) async => JmapMailboxResponse(
          mailboxes: [
            MailboxFixtures.mailboxA,
            MailboxFixtures.mailboxB,
            MailboxFixtures.mailboxC,
            MailboxFixtures.mailboxD
          ],
          state: StateFixtures.newMailboxState
        ));

      final streamMailboxResponses = mailboxRepository.getAllMailbox(sessionFixture, accountIdFixture);

      final listMailboxResponse = await streamMailboxResponses.toList();

      expect(listMailboxResponse.length, 2);
      expect(
        listMailboxResponse.last,
        equals(JmapMailboxResponse(
          mailboxes: [
            MailboxFixtures.mailboxA,
            MailboxFixtures.mailboxB,
            MailboxFixtures.mailboxC,
            MailboxFixtures.mailboxD,
          ],
          state: StateFixtures.newMailboxState
        ))
      );
    });
  });
}