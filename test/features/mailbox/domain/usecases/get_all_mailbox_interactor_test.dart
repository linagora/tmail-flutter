import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/cache_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import '../../../../fixtures/state_fixtures.dart';
import 'get_all_mailbox_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MailboxRepository>()])
void main() {
  late MockMailboxRepository mailboxRepository;
  late GetAllMailboxInteractor interactor;

  setUp(() {
    mailboxRepository = MockMailboxRepository();
    interactor = GetAllMailboxInteractor(mailboxRepository);
  });

  void stubGetAllMailbox(Stream<MailboxResponse> stream) {
    when(mailboxRepository.getAllMailbox(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      properties: anyNamed('properties'),
    )).thenAnswer((_) => stream);
  }

  Future<List<Either<Failure, Success>>> executeInteractor() => interactor
      .execute(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId)
      .toList();

  group('[GetAllMailboxInteractor]', () {
    test('Should emit loading then a success state per response '
        'WHEN the repository stream completes normally', () async {
      stubGetAllMailbox(Stream.fromIterable([
        CacheMailboxResponse(
          mailboxes: [MailboxFixtures.inboxMailbox],
          state: StateFixtures.currentMailboxState,
        ),
        JmapMailboxResponse(
          mailboxes: [MailboxFixtures.inboxMailbox, MailboxFixtures.sentMailbox],
          state: StateFixtures.newMailboxState,
        ),
      ]));

      final states = await executeInteractor();

      expect(states.first, Right<Failure, Success>(GetAllMailboxLoading()));

      final successes = states
          .whereType<Right>()
          .map((state) => state.value)
          .whereType<GetAllMailboxSuccess>()
          .toList();

      expect(successes.length, 2);
      expect(successes.first.mailboxList.length, 1);
      expect(successes.first.currentMailboxState, StateFixtures.currentMailboxState);
      expect(successes.last.mailboxList.length, 2);
      expect(successes.last.currentMailboxState, StateFixtures.newMailboxState);
      expect(states.whereType<Left>(), isEmpty);
    });

    test('Should map every mailbox to its presentation model and forward the '
        'requested properties to the repository', () async {
      final properties = Properties({'id', 'name'});

      stubGetAllMailbox(Stream.fromIterable([
        JmapMailboxResponse(
          mailboxes: [MailboxFixtures.inboxMailbox, MailboxFixtures.sentMailbox],
          state: StateFixtures.newMailboxState,
        ),
      ]));

      final states = await interactor
          .execute(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            properties: properties,
          )
          .toList();

      final success = states
          .whereType<Right>()
          .map((state) => state.value)
          .whereType<GetAllMailboxSuccess>()
          .single;

      expect(success.mailboxList, [
        MailboxFixtures.inboxMailbox.toPresentationMailbox(),
        MailboxFixtures.sentMailbox.toPresentationMailbox(),
      ]);

      verify(mailboxRepository.getAllMailbox(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        properties: properties,
      )).called(1);
    });

    test('Should emit the values already delivered then GetAllMailboxFailure '
        'WHEN the repository stream raises an error midway', () async {
      final exception = StateError('getAllMailbox from JMAP failed');

      stubGetAllMailbox(() async* {
        yield CacheMailboxResponse(
          mailboxes: [MailboxFixtures.inboxMailbox],
          state: StateFixtures.currentMailboxState,
        );
        throw exception;
      }());

      final states = await executeInteractor();

      expect(
        states
            .whereType<Right>()
            .map((state) => state.value)
            .whereType<GetAllMailboxSuccess>()
            .length,
        1,
      );

      final failure = states
          .whereType<Left>()
          .map((state) => state.value)
          .whereType<GetAllMailboxFailure>()
          .single;

      expect(failure.exception, exception);
      expect(failure.onRetry, isNotNull);
    });

    test('Should emit GetAllMailboxFailure '
        'WHEN the repository stream raises an error before any value', () async {
      final exception = StateError('cache unavailable');

      stubGetAllMailbox(Stream<MailboxResponse>.error(exception));

      final states = await executeInteractor();

      final failure = states
          .whereType<Left>()
          .map((state) => state.value)
          .whereType<GetAllMailboxFailure>()
          .single;

      expect(failure.exception, exception);
    });
  });
}
