import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import '../../../../fixtures/state_fixtures.dart';
import 'refresh_all_mailbox_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MailboxRepository>()])
void main() {
  late MockMailboxRepository mailboxRepository;
  late RefreshAllMailboxInteractor interactor;

  setUp(() {
    mailboxRepository = MockMailboxRepository();
    interactor = RefreshAllMailboxInteractor(mailboxRepository);
  });

  void stubRefresh(Stream<MailboxResponse> stream) {
    when(mailboxRepository.refresh(
      SessionFixtures.aliceSession,
      AccountFixtures.aliceAccountId,
      StateFixtures.currentMailboxState,
      properties: anyNamed('properties'),
    )).thenAnswer((_) => stream);
  }

  Future<List<Either<Failure, Success>>> executeInteractor() => interactor
      .execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        StateFixtures.currentMailboxState,
      )
      .toList();

  group('[RefreshAllMailboxInteractor]', () {
    test('Should emit loading then RefreshChangesAllMailboxSuccess '
        'WHEN the repository stream completes normally', () async {
      stubRefresh(Stream.fromIterable([
        JmapMailboxResponse(
          mailboxes: [MailboxFixtures.inboxMailbox, MailboxFixtures.sentMailbox],
          state: StateFixtures.newMailboxState,
        ),
      ]));

      final states = await executeInteractor();

      expect(states.first, Right<Failure, Success>(RefreshChangesAllMailboxLoading()));

      final success = states
          .whereType<Right>()
          .map((state) => state.value)
          .whereType<RefreshChangesAllMailboxSuccess>()
          .single;

      expect(success.mailboxList.length, 2);
      expect(success.currentMailboxState, StateFixtures.newMailboxState);
      expect(states.whereType<Left>(), isEmpty);
    });

    test('Should map every mailbox to its presentation model and forward the '
        'current state and properties to the repository', () async {
      final properties = Properties({'id', 'name'});

      stubRefresh(Stream.fromIterable([
        JmapMailboxResponse(
          mailboxes: [MailboxFixtures.inboxMailbox, MailboxFixtures.sentMailbox],
          state: StateFixtures.newMailboxState,
        ),
      ]));

      final states = await interactor
          .execute(
            SessionFixtures.aliceSession,
            AccountFixtures.aliceAccountId,
            StateFixtures.currentMailboxState,
            properties: properties,
          )
          .toList();

      final success = states
          .whereType<Right>()
          .map((state) => state.value)
          .whereType<RefreshChangesAllMailboxSuccess>()
          .single;

      expect(success.mailboxList, [
        MailboxFixtures.inboxMailbox.toPresentationMailbox(),
        MailboxFixtures.sentMailbox.toPresentationMailbox(),
      ]);

      verify(mailboxRepository.refresh(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        StateFixtures.currentMailboxState,
        properties: properties,
      )).called(1);
    });

    test('Should emit RefreshChangesAllMailboxFailure '
        'WHEN the repository stream raises an error midway', () async {
      final exception = StateError('getChanges failed');

      stubRefresh(() async* {
        yield JmapMailboxResponse(
          mailboxes: [MailboxFixtures.inboxMailbox],
          state: StateFixtures.newMailboxState,
        );
        throw exception;
      }());

      final states = await executeInteractor();

      expect(
        states
            .whereType<Right>()
            .map((state) => state.value)
            .whereType<RefreshChangesAllMailboxSuccess>()
            .length,
        1,
      );

      final failure = states
          .whereType<Left>()
          .map((state) => state.value)
          .whereType<RefreshChangesAllMailboxFailure>()
          .single;

      expect(failure.exception, exception);
    });

    test('Should emit RefreshChangesAllMailboxFailure '
        'WHEN the repository stream raises an error before any value', () async {
      final exception = StateError('state cache missing');

      stubRefresh(Stream<MailboxResponse>.error(exception));

      final states = await executeInteractor();

      final failure = states
          .whereType<Left>()
          .map((state) => state.value)
          .whereType<RefreshChangesAllMailboxFailure>()
          .single;

      expect(failure.exception, exception);
    });
  });
}
