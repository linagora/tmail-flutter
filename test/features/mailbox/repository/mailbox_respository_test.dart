import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
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

  group('[deleteMultipleMailbox] method test', () {
    final mailboxIdA = MailboxId(Id('A'));
    final mailboxIdB = MailboxId(Id('B'));
    final mailboxIdC = MailboxId(Id('C'));

    setUp(() {
      mailboxDataSource = MockMailboxDataSource();
      mailboxCacheDataSourceImpl = MockMailboxCacheDataSourceImpl();
      stateDataSource = MockStateDataSource();
      mailboxRepository = MailboxRepositoryImpl(
        {
          DataSourceType.network: mailboxDataSource,
          DataSourceType.local: mailboxCacheDataSourceImpl,
        },
        stateDataSource,
      );
    });

    test(
      'SHOULD call local update with all IDs as destroyed \n'
      'WHEN network returns an empty error map (all deleted)',
    () async {
      when(mailboxDataSource.deleteMultipleMailbox(sessionFixture, accountIdFixture, [mailboxIdA, mailboxIdB]))
        .thenAnswer((_) async => {});
      when(mailboxCacheDataSourceImpl.update(accountIdFixture, userNameFixture, destroyed: anyNamed('destroyed')))
        .thenAnswer((_) async {});

      await mailboxRepository.deleteMultipleMailbox(sessionFixture, accountIdFixture, [mailboxIdA, mailboxIdB]);

      verify(mailboxCacheDataSourceImpl.update(
        accountIdFixture,
        userNameFixture,
        destroyed: [mailboxIdA, mailboxIdB],
      )).called(1);
    });

    test(
      'SHOULD call local update with only successfully deleted IDs \n'
      'WHEN network returns a non-empty error map (partial failure)',
    () async {
      when(mailboxDataSource.deleteMultipleMailbox(sessionFixture, accountIdFixture, [mailboxIdA, mailboxIdB, mailboxIdC]))
        .thenAnswer((_) async => {mailboxIdB.id: SetError(ErrorType('serverFail'))});
      when(mailboxCacheDataSourceImpl.update(accountIdFixture, userNameFixture, destroyed: anyNamed('destroyed')))
        .thenAnswer((_) async {});

      await mailboxRepository.deleteMultipleMailbox(sessionFixture, accountIdFixture, [mailboxIdA, mailboxIdB, mailboxIdC]);

      verify(mailboxCacheDataSourceImpl.update(
        accountIdFixture,
        userNameFixture,
        destroyed: [mailboxIdA, mailboxIdC],
      )).called(1);
    });

    test(
      'SHOULD return the original error map \n'
      'WHEN local cache update throws',
    () async {
      when(mailboxDataSource.deleteMultipleMailbox(sessionFixture, accountIdFixture, [mailboxIdA]))
        .thenAnswer((_) async => {});
      when(mailboxCacheDataSourceImpl.update(accountIdFixture, userNameFixture, destroyed: anyNamed('destroyed')))
        .thenThrow(Exception('cache error'));

      final result = await mailboxRepository.deleteMultipleMailbox(sessionFixture, accountIdFixture, [mailboxIdA]);

      expect(result, isEmpty);
    });

    test(
      'SHOULD NOT call local update \n'
      'WHEN all IDs are in the network error map (all failed)',
    () async {
      when(mailboxDataSource.deleteMultipleMailbox(sessionFixture, accountIdFixture, [mailboxIdA, mailboxIdB]))
        .thenAnswer((_) async => {
          mailboxIdA.id: SetError(ErrorType('serverFail')),
          mailboxIdB.id: SetError(ErrorType('serverFail')),
        });

      await mailboxRepository.deleteMultipleMailbox(sessionFixture, accountIdFixture, [mailboxIdA, mailboxIdB]);

      verifyNever(mailboxCacheDataSourceImpl.update(accountIdFixture, userNameFixture, destroyed: anyNamed('destroyed')));
    });
  });
}