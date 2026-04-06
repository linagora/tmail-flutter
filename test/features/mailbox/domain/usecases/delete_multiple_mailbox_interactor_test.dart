import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/mailbox_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'delete_multiple_mailbox_interactor_test.mocks.dart';

@GenerateMocks([MailboxRepository])

void _stubGetMailboxState(MailboxRepository repo, jmap.State state) {
  when(
    repo.getMailboxState(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId),
  ).thenAnswer((_) => Future.value(state));
}

void _stubGetAllMailboxWithHiddenMailboxes(MailboxRepository repo, jmap.State state) {
  when(
    repo.getAllMailbox(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId),
  ).thenAnswer((_) => Stream.fromIterable({
    JmapMailboxResponse(
      mailboxes: [
        MailboxFixtures.inboxMailbox,
        MailboxFixtures.sentMailbox,
        MailboxFixtures.selectedFolderToDelete,
        MailboxFixtures.selectedFolderToDelete_1,
        MailboxFixtures.selectedFolderToDelete_2,
      ],
      state: state,
    ),
    JmapMailboxResponse(
      mailboxes: [
        MailboxFixtures.inboxMailbox,
        MailboxFixtures.sentMailbox,
        MailboxFixtures.selectedFolderToDelete,
        MailboxFixtures.selectedFolderToDelete_1,
        MailboxFixtures.selectedFolderToDelete_2,
        MailboxFixtures.selectedFolderToDelete_3,
        MailboxFixtures.selectedFolderToDelete_4,
        MailboxFixtures.selectedFolderToDelete_5,
        MailboxFixtures.selectedFolderToDelete_6,
        MailboxFixtures.selectedFolderToDelete_7,
        MailboxFixtures.selectedFolderToDelete_8,
        MailboxFixtures.selectedFolderToDelete_9,
        MailboxFixtures.selectedFolderToDelete_10,
      ],
      state: state,
    ),
  }));
}

void _stubGetAllMailboxWithSubscribedFolders(MailboxRepository repo, jmap.State state) {
  when(
    repo.getAllMailbox(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId),
  ).thenAnswer((_) => Stream.value(JmapMailboxResponse(
    mailboxes: [MailboxFixtures.subscribedFolder, MailboxFixtures.subscribedChild],
    state: state,
  )));
}

void _stubDeleteMailboxSuccess(MailboxRepository repo, List<MailboxId> ids) {
  when(
    repo.deleteMultipleMailbox(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId, ids),
  ).thenAnswer((_) => Future.value({}));
}

void _stubDeleteMailboxFailure(
  MailboxRepository repo,
  List<MailboxId> ids,
  Map<Id, SetError> errors,
) {
  when(
    repo.deleteMultipleMailbox(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId, ids),
  ).thenAnswer((_) => Future.value(errors));
}

Stream<dynamic> _executeDelete(
  DeleteMultipleMailboxInteractor interactor,
  List<MailboxId> ids,
) => interactor.execute(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId, ids);

Matcher _emitsLoadingThen(dynamic result) => emitsInOrder([
  Right(LoadingDeleteMultipleMailboxAll()),
  result,
]);

void main() {
  late MailboxRepository mailboxRepository;
  late DeleteMultipleMailboxInteractor deleteMultipleMailboxInteractor;

  group('[DeleteMultipleMailboxInteractor]', () {
    setUp(() {
      mailboxRepository = MockMailboxRepository();
      deleteMultipleMailboxInteractor = DeleteMultipleMailboxInteractor(mailboxRepository);
    });

    group('with hidden mailbox responses', () {
      final state = jmap.State('s1');

      setUp(() {
        _stubGetMailboxState(mailboxRepository, state);
        _stubGetAllMailboxWithHiddenMailboxes(mailboxRepository, state);
        // second batch defaults to success; override per-test when needed
        _stubDeleteMailboxSuccess(mailboxRepository, MailboxFixtures.listDescendantMailboxForSelectedFolder2);
      });

      test('Should execute to delete selected mailbox an all its children included hidden mailbox', () {
        _stubDeleteMailboxSuccess(mailboxRepository, MailboxFixtures.listDescendantMailboxForSelectedFolder);

        expect(
          _executeDelete(deleteMultipleMailboxInteractor, MailboxFixtures.listMailboxIdsToDelete),
          _emitsLoadingThen(Right(DeleteMultipleMailboxAllSuccess(
            MailboxFixtures.listMailboxIdToDelete,
            currentMailboxState: state,
          ))),
        );
      });

      test('Should execute and yield DeleteMultipleMailboxAllFailure when delete selected mailbox all fail', () {
        _stubDeleteMailboxFailure(
          mailboxRepository,
          MailboxFixtures.listDescendantMailboxForSelectedFolder,
          {Id('folderToDelete'): SetError(ErrorType('error'))},
        );
        _stubDeleteMailboxFailure(
          mailboxRepository,
          MailboxFixtures.listDescendantMailboxForSelectedFolder2,
          {Id('folderToDelete_8'): SetError(ErrorType('error'))},
        );

        expect(
          _executeDelete(deleteMultipleMailboxInteractor, MailboxFixtures.listMailboxIdsToDelete),
          _emitsLoadingThen(Left(DeleteMultipleMailboxAllFailure())),
        );
      });

      test('Should execute and yield DeleteMultipleMailboxHasSomeSuccess when delete selected mailbox has some fail', () {
        _stubDeleteMailboxFailure(
          mailboxRepository,
          MailboxFixtures.listDescendantMailboxForSelectedFolder,
          {Id('folderToDelete'): SetError(ErrorType('error'))},
        );

        expect(
          _executeDelete(deleteMultipleMailboxInteractor, MailboxFixtures.listMailboxIdsToDelete),
          _emitsLoadingThen(Right(DeleteMultipleMailboxHasSomeSuccess(
            MailboxFixtures.listMailboxIdToDelete,
            currentMailboxState: state,
          ))),
        );
      });
    });

    test('Should yield AllSuccess with empty lists when selectedMailboxIds is empty', () {
      final state = jmap.State('s1');
      _stubGetMailboxState(mailboxRepository, state);
      when(
        mailboxRepository.getAllMailbox(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId),
      ).thenAnswer((_) => Stream.value(JmapMailboxResponse(
        mailboxes: [MailboxFixtures.inboxMailbox, MailboxFixtures.sentMailbox],
        state: state,
      )));

      expect(
        _executeDelete(deleteMultipleMailboxInteractor, []),
        _emitsLoadingThen(Right(DeleteMultipleMailboxAllSuccess(
          [],
          currentMailboxState: state,
        ))),
      );
    });

    test('Should execute and yield DeleteMultipleMailboxFailure when getAllMailbox fail', () {
      final state = jmap.State('s1');
      _stubGetMailboxState(mailboxRepository, state);
      when(
        mailboxRepository.getAllMailbox(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId),
      ).thenThrow('error');

      expect(
        _executeDelete(deleteMultipleMailboxInteractor, MailboxFixtures.listMailboxIdsToDelete),
        _emitsLoadingThen(Left(DeleteMultipleMailboxFailure('error'))),
      );
    });

    test('Should delete selected mailbox alone when it is absent from allMailboxes (no children found)', () {
      final state = jmap.State('s1');
      final ghostMailboxId = MailboxId(Id('ghostMailbox'));
      _stubGetMailboxState(mailboxRepository, state);
      when(
        mailboxRepository.getAllMailbox(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId),
      ).thenAnswer((_) => Stream.value(JmapMailboxResponse(
        mailboxes: [MailboxFixtures.inboxMailbox, MailboxFixtures.sentMailbox],
        state: state,
      )));
      _stubDeleteMailboxSuccess(mailboxRepository, [ghostMailboxId]);

      expect(
        _executeDelete(deleteMultipleMailboxInteractor, [ghostMailboxId]),
        _emitsLoadingThen(Right(DeleteMultipleMailboxAllSuccess(
          [ghostMailboxId],
          currentMailboxState: state,
        ))),
      );
    });

    group('with subscribed folders', () {
      final state = jmap.State('s1');

      setUp(() {
        _stubGetMailboxState(mailboxRepository, state);
        _stubGetAllMailboxWithSubscribedFolders(mailboxRepository, state);
        _stubDeleteMailboxSuccess(mailboxRepository, MailboxFixtures.expectedDeleteListSubscribedOnly);
      });

      test('Should delete subscribed child before parent when no hidden subfolders exist', () {
        expect(
          _executeDelete(deleteMultipleMailboxInteractor, MailboxFixtures.listMailboxIdsForSubscribedOnly),
          _emitsLoadingThen(Right(DeleteMultipleMailboxAllSuccess(
            MailboxFixtures.expectedDeleteListSubscribedOnly,
            currentMailboxState: state,
          ))),
        );
      });

      test('Should skip already-processed descendant when it also appears in selectedMailboxIds', () {
        // subscribedChild is a descendant of subscribedFolder — it must be skipped
        // as a root and subsumed into the parent's batch instead.
        expect(
          _executeDelete(deleteMultipleMailboxInteractor, [
            MailboxFixtures.subscribedFolder.id!,
            MailboxFixtures.subscribedChild.id!,
          ]),
          _emitsLoadingThen(Right(DeleteMultipleMailboxAllSuccess(
            MailboxFixtures.expectedDeleteListSubscribedOnly,
            currentMailboxState: state,
          ))),
        );
      });
    });

    test('Should delete 3-level unsubscribed nesting in deepest-first order', () {
      final state = jmap.State('s1');
      _stubGetMailboxState(mailboxRepository, state);
      when(
        mailboxRepository.getAllMailbox(SessionFixtures.aliceSession, AccountFixtures.aliceAccountId),
      ).thenAnswer((_) => Stream.value(JmapMailboxResponse(
        mailboxes: [
          MailboxFixtures.parentFolder,
          MailboxFixtures.hiddenLevel1,
          MailboxFixtures.hiddenLevel2,
          MailboxFixtures.hiddenLevel3,
        ],
        state: state,
      )));
      _stubDeleteMailboxSuccess(mailboxRepository, MailboxFixtures.expectedDeleteListThreeLevelNesting);

      expect(
        _executeDelete(deleteMultipleMailboxInteractor, [MailboxFixtures.parentFolder.id!]),
        _emitsLoadingThen(Right(DeleteMultipleMailboxAllSuccess(
          MailboxFixtures.expectedDeleteListThreeLevelNesting,
          currentMailboxState: state,
        ))),
      );
    });
  });
}
