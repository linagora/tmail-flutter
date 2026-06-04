import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/clear_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/empty_folder_provider.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'empty_trash_notifier_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ClearMailboxInteractor>(),
  MockSpec<EmptyTrashFolderInteractor>(),
  MockSpec<DeleteMultipleMailboxInteractor>(),
])
void main() {
  late MockClearMailboxInteractor mockClearInteractor;
  late MockEmptyTrashFolderInteractor mockEmailDeletionInteractor;
  late MockDeleteMultipleMailboxInteractor mockSubfoldersInteractor;
  late ProviderContainer container;
  late EmptyFolderNotifier notifier;

  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;

  final trashMailboxId = MailboxId(Id('trash-1'));
  final trashMailbox = PresentationMailbox(
    trashMailboxId,
    name: MailboxName('Trash'),
    role: PresentationMailbox.roleTrash,
    totalEmails: TotalEmails(UnsignedInt(5)),
  );
  final emptyTrashMailbox = PresentationMailbox(
    trashMailboxId,
    name: MailboxName('Trash'),
    role: PresentationMailbox.roleTrash,
  );
  final childIds = [MailboxId(Id('child-1')), MailboxId(Id('child-2'))];
  final emailIds = [EmailId(Id('email-1'))];

  setUp(() {
    mockClearInteractor = MockClearMailboxInteractor();
    mockEmailDeletionInteractor = MockEmptyTrashFolderInteractor();
    mockSubfoldersInteractor = MockDeleteMultipleMailboxInteractor();

    Get.put<ClearMailboxInteractor>(mockClearInteractor);
    Get.put<EmptyTrashFolderInteractor>(mockEmailDeletionInteractor);
    Get.put<DeleteMultipleMailboxInteractor>(mockSubfoldersInteractor);

    container = ProviderContainer();
    notifier = container.read(
      emptyFolderProvider(trashMailboxId).notifier,
    );
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  void stubClearSuccess() {
    when(mockClearInteractor.execute(any, any, any, any)).thenAnswer(
      (_) => Stream.value(
        Right<Failure, Success>(
          ClearMailboxSuccess(
            trashMailboxId,
            PresentationMailbox.roleTrash,
            UnsignedInt(0),
          ),
        ),
      ),
    );
  }

  void stubClearDelayed(Duration delay) {
    when(mockClearInteractor.execute(any, any, any, any)).thenAnswer((
      _,
    ) async* {
      await Future<void>.delayed(delay);
      yield Right<Failure, Success>(
        ClearMailboxSuccess(
          trashMailboxId,
          PresentationMailbox.roleTrash,
          UnsignedInt(0),
        ),
      );
    });
  }

  void stubSubfoldersResult(Either<Failure, Success> result) {
    when(
      mockSubfoldersInteractor.execute(any, any, any),
    ).thenAnswer((_) => Stream.value(result));
  }

  List<EmptyFolderState> listenStates() {
    final states = <EmptyFolderState>[];
    container.listen(
      emptyFolderProvider(trashMailboxId),
      (_, EmptyFolderState next) => states.add(next),
      fireImmediately: false,
    );
    return states;
  }

  EmptyFolderSuccess readSuccess() =>
      container.read(emptyFolderProvider(trashMailboxId))
          as EmptyFolderSuccess;

  Future<void> expectInteractorErrorEmitsFailure({
    required Exception error,
    required void Function(Exception) stubThrow,
    required bool useJmapClear,
    bool verifyMailboxId = false,
  }) async {
    stubThrow(error);
    await notifier.execute(session, accountId, trashMailbox, [], useJmapClear);
    final state = container.read(emptyFolderProvider(trashMailboxId));
    expect(state, isA<EmptyFolderFailure>());
    final failure = state as EmptyFolderFailure;
    expect(failure.exception, error);
    if (verifyMailboxId) expect(failure.mailboxId, trashMailboxId);
  }

  group('EmptyFolderNotifier', () {
    group('initial state', () {
      test('starts as EmptyFolderIdle', () {
        expect(
          container.read(emptyFolderProvider(trashMailboxId)),
          isA<EmptyFolderIdle>(),
        );
      });
    });

    group('execute — guard condition', () {
      test('does nothing when already loading', () async {
        stubClearDelayed(const Duration(milliseconds: 100));

        final firstCall = notifier.execute(
          session,
          accountId,
          trashMailbox,
          [],
          true,
        );
        await notifier.execute(session, accountId, trashMailbox, [], true);
        await firstCall;

        verify(mockClearInteractor.execute(any, any, any, any)).called(1);
      });
    });

    group('execute — JMAP clear path (useJmapClear = true)', () {
      test(
        'emits Loading then Success when clear succeeds with no subfolders',
        () async {
          final states = listenStates();

          when(mockClearInteractor.execute(any, any, any, any)).thenAnswer(
            (_) => Stream.value(
              Right<Failure, Success>(
                ClearMailboxSuccess(
                  trashMailboxId,
                  PresentationMailbox.roleTrash,
                  UnsignedInt(5),
                ),
              ),
            ),
          );

          await notifier.execute(session, accountId, trashMailbox, [], true);

          expect(states, [
            isA<EmptyFolderLoading>(),
            isA<EmptyFolderSuccess>(),
          ]);

          final success = states.last as EmptyFolderSuccess;
          expect(success.subfoldersStatus, SubfoldersDeleteStatus.none);
          expect(success.mailboxId, trashMailboxId);

          verifyNever(mockSubfoldersInteractor.execute(any, any, any));
        },
      );

      test('deletes subfolders even when mailbox has no emails', () async {
        stubSubfoldersResult(Right(DeleteMultipleMailboxAllSuccess(childIds)));

        await notifier.execute(
          session,
          accountId,
          emptyTrashMailbox,
          childIds,
          true,
        );

        expect(
          readSuccess().subfoldersStatus,
          SubfoldersDeleteStatus.allDeleted,
        );
        verifyNever(mockClearInteractor.execute(any, any, any, any));
        verifyNever(
          mockEmailDeletionInteractor.execute(any, any, any, any, any),
        );
      });

      group('with successful email clear', () {
        setUp(stubClearSuccess);

        test('also deletes subfolders when childIds is not empty', () async {
          stubSubfoldersResult(
            Right(DeleteMultipleMailboxAllSuccess(childIds)),
          );

          await notifier.execute(
            session,
            accountId,
            trashMailbox,
            childIds,
            true,
          );

          expect(
            readSuccess().subfoldersStatus,
            SubfoldersDeleteStatus.allDeleted,
          );
        });

        test(
          'emits Success with subfoldersSomeDeleted when HasSomeSuccess',
          () async {
            stubSubfoldersResult(
              Right(DeleteMultipleMailboxHasSomeSuccess(childIds)),
            );

            await notifier.execute(
              session,
              accountId,
              trashMailbox,
              childIds,
              true,
            );

            expect(
              readSuccess().subfoldersStatus,
              SubfoldersDeleteStatus.someDeleted,
            );
          },
        );

        test(
          'emits Success with subfoldersDeleteFailed when subfolder deletion fails',
          () async {
            stubSubfoldersResult(Left(DeleteMultipleMailboxAllFailure()));

            await notifier.execute(
              session,
              accountId,
              trashMailbox,
              childIds,
              true,
            );

            expect(
              readSuccess().subfoldersStatus,
              SubfoldersDeleteStatus.failed,
            );
          },
        );
      });

      test('emits Failure when interactor is not registered', () async {
        Get.reset();
        container.dispose();
        container = ProviderContainer();
        notifier = container.read(
          emptyFolderProvider(trashMailboxId).notifier,
        );

        await notifier.execute(session, accountId, trashMailbox, [], true);

        expect(
          container.read(emptyFolderProvider(trashMailboxId)),
          isA<EmptyFolderFailure>(),
        );
      });
    });

    group('execute — email-by-email path (useJmapClear = false)', () {
      test('emits Loading then Success when EmptyTrashFolderSuccess', () async {
        final states = listenStates();

        when(
          mockEmailDeletionInteractor.execute(any, any, any, any, any),
        ).thenAnswer(
          (_) => Stream.value(
            Right<Failure, Success>(
              EmptyTrashFolderSuccess(emailIds, trashMailboxId),
            ),
          ),
        );

        await notifier.execute(session, accountId, trashMailbox, [], false);

        expect(states, [isA<EmptyFolderLoading>(), isA<EmptyFolderSuccess>()]);

        final success = states.last as EmptyFolderSuccess;
        expect(success.clearedEmailIds, emailIds);
        expect(success.mailboxId, trashMailboxId);
      });

      test(
        'emits EmptyFolderInProgress states as progress events arrive',
        () async {
          final states = listenStates();

          when(
            mockEmailDeletionInteractor.execute(any, any, any, any, any),
          ).thenAnswer((invocation) async* {
            final progressCtrl =
                invocation.positionalArguments[4]
                    as StreamController<Either<Failure, Success>>;
            progressCtrl.add(Right(EmptyingFolderState(trashMailboxId, 2, 5)));
            progressCtrl.add(Right(EmptyingFolderState(trashMailboxId, 5, 5)));
            yield Right<Failure, Success>(
              EmptyTrashFolderSuccess(emailIds, trashMailboxId),
            );
          });

          await notifier.execute(session, accountId, trashMailbox, [], false);

          expect(states, [
            isA<EmptyFolderLoading>(),
            isA<EmptyFolderInProgress>(),
            isA<EmptyFolderInProgress>(),
            isA<EmptyFolderSuccess>(),
          ]);

          final firstProgress = states[1] as EmptyFolderInProgress;
          expect(firstProgress.mailboxId, trashMailboxId);
          expect(firstProgress.countEmailsDeleted, 2);
          expect(firstProgress.totalEmails, 5);

          final lastProgress = states[2] as EmptyFolderInProgress;
          expect(lastProgress.countEmailsDeleted, 5);
        },
      );

    });

    group('emits Failure when interactor throws', () {
      for (final (name, useJmapClear, verifyMailboxId, doStub) in [
        (
          'JMAP clear path',
          true,
          true,
          (Exception error) {
            when(
              mockClearInteractor.execute(any, any, any, any),
            ).thenAnswer((_) => Stream.error(error));
          },
        ),
        (
          'email-by-email path',
          false,
          false,
          (Exception error) {
            when(
              mockEmailDeletionInteractor.execute(any, any, any, any, any),
            ).thenAnswer((_) => Stream.error(error));
          },
        ),
      ]) {
        test(name, () async {
          await expectInteractorErrorEmitsFailure(
            error: Exception('interactor error'),
            stubThrow: doStub,
            useJmapClear: useJmapClear,
            verifyMailboxId: verifyMailboxId,
          );
        });
      }
    });

    group('mounted guard', () {
      test('does not throw when provider disposed during operation', () async {
        stubClearDelayed(const Duration(milliseconds: 50));

        final call = notifier.execute(
          session,
          accountId,
          trashMailbox,
          [],
          true,
        );
        container.dispose();

        await expectLater(call, completes);
      });
    });
  });
}
