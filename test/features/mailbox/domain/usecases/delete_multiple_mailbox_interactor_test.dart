import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
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

void main() {
  late MailboxRepository mailboxRepository;
  late DeleteMultipleMailboxInteractor deleteMultipleMailboxInteractor;

  group('[DeleteMultipleMailboxInteractor]', () {
    setUp(() {
      mailboxRepository = MockMailboxRepository();
      deleteMultipleMailboxInteractor = DeleteMultipleMailboxInteractor(mailboxRepository);
    });

    test('Should execute to delete selected mailbox an all its children included hidden mailbox', () {
      final state = jmap.State('s1');
      
      when(
        mailboxRepository.getMailboxState(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId
        )
      ).thenAnswer((_) => Future.value(state));

      when(
        mailboxRepository.getAllMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId
        )
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

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.listDescendantMailboxForSelectedFolder,
        )
      ).thenAnswer((_) => Future.value({}));

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.listDescendantMailboxForSelectedFolder2,
        )
      ).thenAnswer((_) => Future.value({}));

      final result = deleteMultipleMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        MailboxFixtures.listMailboxIdsToDelete
      );

      expect(result, emitsInOrder([
        Right(LoadingDeleteMultipleMailboxAll()),
        Right(DeleteMultipleMailboxAllSuccess(
          MailboxFixtures.listMailboxIdToDelete,
          currentMailboxState: state
        )),
      ]));
    });

    test('Should execute and yield DeleteMultipleMailboxAllFailure when delete selected mailbox all fail', () {
      final state = jmap.State('s1');
      
      when(
        mailboxRepository.getMailboxState(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId
        )
      ).thenAnswer((_) => Future.value(state));

      when(
        mailboxRepository.getAllMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId
        )
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

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.listDescendantMailboxForSelectedFolder,
        )
      ).thenAnswer((_) => Future.value({
        Id('folderToDelete'): SetError(ErrorType('error')),
      }));

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.listDescendantMailboxForSelectedFolder2,
        )
      ).thenAnswer((_) => Future.value({
        Id('folderToDelete_8'): SetError(ErrorType('error')),
      }));

      final result = deleteMultipleMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        MailboxFixtures.listMailboxIdsToDelete
      );

      expect(result, emitsInOrder([
        Right(LoadingDeleteMultipleMailboxAll()),
        Left(DeleteMultipleMailboxAllFailure()),
      ]));
    });

    test('Should execute and yield DeleteMultipleMailboxHasSomeSuccess when delete selected mailbox has some fail', () {
      final state = jmap.State('s1');
      
      when(
        mailboxRepository.getMailboxState(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId
        )
      ).thenAnswer((_) => Future.value(state));

      when(
        mailboxRepository.getAllMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId
        )
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

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.listDescendantMailboxForSelectedFolder,
        )
      ).thenAnswer((_) => Future.value({
        Id('folderToDelete'): SetError(ErrorType('error')),
      }));

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.listDescendantMailboxForSelectedFolder2,
        )
      ).thenAnswer((_) => Future.value({}));

      final result = deleteMultipleMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        MailboxFixtures.listMailboxIdsToDelete
      );

      expect(result, emitsInOrder([
        Right(LoadingDeleteMultipleMailboxAll()),
        Right(DeleteMultipleMailboxHasSomeSuccess(
          MailboxFixtures.listMailboxIdToDelete,
          currentMailboxState: state
        )),
      ]));
    });

    test('Should execute and yield DeleteMultipleMailboxFailure when getAllMailbox fail', () {
      final state = jmap.State('s1');

      when(
        mailboxRepository.getMailboxState(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId
        )
      ).thenAnswer((_) => Future.value(state));

      when(
        mailboxRepository.getAllMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId
        )
      ).thenThrow('error');

      final result = deleteMultipleMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        MailboxFixtures.listMailboxIdsToDelete
      );

      expect(result, emitsInOrder([
        Right(LoadingDeleteMultipleMailboxAll()),
        Left(DeleteMultipleMailboxFailure('error')),
      ]));
    });

    test('Should delete subscribed child before parent when no hidden subfolders exist', () {
      final state = jmap.State('s1');

      when(
        mailboxRepository.getMailboxState(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
      ).thenAnswer((_) => Future.value(state));

      when(
        mailboxRepository.getAllMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
      ).thenAnswer((_) => Stream.value(
        JmapMailboxResponse(
          mailboxes: [
            MailboxFixtures.subscribedFolder,
            MailboxFixtures.subscribedChild,
          ],
          state: state,
        ),
      ));

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.expectedDeleteListSubscribedOnly,
        ),
      ).thenAnswer((_) => Future.value({}));

      final result = deleteMultipleMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        MailboxFixtures.listMailboxIdsForSubscribedOnly,
      );

      expect(result, emitsInOrder([
        Right(LoadingDeleteMultipleMailboxAll()),
        Right(DeleteMultipleMailboxAllSuccess(
          MailboxFixtures.expectedDeleteListSubscribedOnly,
          currentMailboxState: state,
        )),
      ]));
    });

    test('Should delete 3-level unsubscribed nesting in deepest-first order', () {
      final state = jmap.State('s1');

      when(
        mailboxRepository.getMailboxState(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
      ).thenAnswer((_) => Future.value(state));

      when(
        mailboxRepository.getAllMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
      ).thenAnswer((_) => Stream.value(
        JmapMailboxResponse(
          mailboxes: [
            MailboxFixtures.parentFolder,
            MailboxFixtures.hiddenLevel1,
            MailboxFixtures.hiddenLevel2,
            MailboxFixtures.hiddenLevel3,
          ],
          state: state,
        ),
      ));

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.expectedDeleteListThreeLevelNesting,
        ),
      ).thenAnswer((_) => Future.value({}));

      final result = deleteMultipleMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        [MailboxFixtures.parentFolder.id!],
      );

      expect(result, emitsInOrder([
        Right(LoadingDeleteMultipleMailboxAll()),
        Right(DeleteMultipleMailboxAllSuccess(
          MailboxFixtures.expectedDeleteListThreeLevelNesting,
          currentMailboxState: state,
        )),
      ]));
    });

    test('Should skip already-processed descendant when it also appears in selectedMailboxIds', () {
      final state = jmap.State('s1');

      when(
        mailboxRepository.getMailboxState(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
      ).thenAnswer((_) => Future.value(state));

      when(
        mailboxRepository.getAllMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
        ),
      ).thenAnswer((_) => Stream.value(
        JmapMailboxResponse(
          mailboxes: [
            MailboxFixtures.subscribedFolder,
            MailboxFixtures.subscribedChild,
          ],
          state: state,
        ),
      ));

      when(
        mailboxRepository.deleteMultipleMailbox(
          SessionFixtures.aliceSession,
          AccountFixtures.aliceAccountId,
          MailboxFixtures.expectedDeleteListSubscribedOnly,
        ),
      ).thenAnswer((_) => Future.value({}));

      // subscribedChild is a descendant of subscribedFolder — it must be skipped
      // as a root and subsumed into the parent's batch instead.
      final result = deleteMultipleMailboxInteractor.execute(
        SessionFixtures.aliceSession,
        AccountFixtures.aliceAccountId,
        [
          MailboxFixtures.subscribedFolder.id!,
          MailboxFixtures.subscribedChild.id!,
        ],
      );

      expect(result, emitsInOrder([
        Right(LoadingDeleteMultipleMailboxAll()),
        Right(DeleteMultipleMailboxAllSuccess(
          MailboxFixtures.expectedDeleteListSubscribedOnly,
          currentMailboxState: state,
        )),
      ]));
    });
  });
}