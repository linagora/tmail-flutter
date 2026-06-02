import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/delete_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/providers/delete_trash_subfolders_provider.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'delete_trash_subfolders_notifier_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DeleteMultipleMailboxInteractor>()])
void main() {
  late MockDeleteMultipleMailboxInteractor mockInteractor;
  late ProviderContainer container;
  late DeleteTrashSubfoldersNotifier notifier;

  final session = SessionFixtures.aliceSession;
  final accountId = AccountFixtures.aliceAccountId;
  final childIds = [
    MailboxId(Id('child-1')),
    MailboxId(Id('child-2')),
  ];

  Future<DeleteTrashSubfoldersState> runExecuteAndReadState(
    Stream<Either<Failure, Success>> stream,
  ) async {
    when(mockInteractor.execute(any, any, any)).thenAnswer((_) => stream);
    await notifier.execute(session, accountId, childIds);
    return container.read(deleteTrashSubfoldersProvider);
  }

  setUp(() {
    mockInteractor = MockDeleteMultipleMailboxInteractor();
    Get.put<DeleteMultipleMailboxInteractor>(mockInteractor);
    container = ProviderContainer();
    notifier = container.read(deleteTrashSubfoldersProvider.notifier);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  group('DeleteTrashSubfoldersNotifier', () {
    group('initial state', () {
      test('starts as Idle', () {
        expect(container.read(deleteTrashSubfoldersProvider),
            isA<DeleteTrashSubfoldersIdle>());
      });
    });

    group('execute — guard conditions', () {
      test('does nothing when childIds is empty', () async {
        await notifier.execute(session, accountId, []);

        expect(container.read(deleteTrashSubfoldersProvider),
            isA<DeleteTrashSubfoldersIdle>());
        verifyNever(mockInteractor.execute(any, any, any));
      });

      test('does nothing when already loading', () async {
        when(mockInteractor.execute(any, any, any)).thenAnswer(
          (_) => Stream.fromFuture(
            Future.delayed(
              const Duration(milliseconds: 100),
              () => Right<Failure, Success>(
                DeleteMultipleMailboxAllSuccess(childIds),
              ),
            ),
          ),
        );

        // Start first call (will be in Loading state)
        final firstCall = notifier.execute(session, accountId, childIds);

        // Immediately trigger second call while first is Loading
        await notifier.execute(session, accountId, childIds);

        await firstCall;

        // Interactor should only have been called once
        verify(mockInteractor.execute(any, any, any)).called(1);
      });
    });

    group('execute — success paths', () {
      test('transitions Loading → Success on AllSuccess', () async {
        final states = <DeleteTrashSubfoldersState>[];
        final sub = container.listen(
          deleteTrashSubfoldersProvider,
          (_, next) => states.add(next),
          fireImmediately: false,
        );

        when(mockInteractor.execute(any, any, any)).thenAnswer(
          (_) => Stream.fromIterable([
            Right<Failure, Success>(LoadingDeleteMultipleMailboxAll()),
            Right<Failure, Success>(DeleteMultipleMailboxAllSuccess(childIds)),
          ]),
        );

        await notifier.execute(session, accountId, childIds);

        expect(states, [
          isA<DeleteTrashSubfoldersLoading>(),
          isA<DeleteTrashSubfoldersSuccess>(),
        ]);

        sub.close();
      });

      test('transitions Loading → PartialSuccess on HasSomeSuccess', () async {
        final state = await runExecuteAndReadState(Stream.fromIterable([
          Right<Failure, Success>(LoadingDeleteMultipleMailboxAll()),
          Right<Failure, Success>(DeleteMultipleMailboxHasSomeSuccess(childIds)),
        ]));

        expect(state, isA<DeleteTrashSubfoldersPartialSuccess>());
      });

      test('allows second execute after first completes', () async {
        when(mockInteractor.execute(any, any, any)).thenAnswer(
          (_) => Stream.value(
            Right<Failure, Success>(DeleteMultipleMailboxAllSuccess(childIds)),
          ),
        );

        await notifier.execute(session, accountId, childIds);
        await notifier.execute(session, accountId, childIds);

        verify(mockInteractor.execute(any, any, any)).called(2);
      });
    });

    group('execute — failure paths', () {
      test('transitions Loading → Failed on AllFailure', () async {
        final state = await runExecuteAndReadState(Stream.fromIterable([
          Right<Failure, Success>(LoadingDeleteMultipleMailboxAll()),
          Left<Failure, Success>(DeleteMultipleMailboxAllFailure()),
        ]));

        expect(state, isA<DeleteTrashSubfoldersFailed>());
      });

      test('transitions Loading → Failed and captures exception on throw',
          () async {
        final error = Exception('network error');
        when(mockInteractor.execute(any, any, any))
            .thenAnswer((_) => Stream.error(error));

        await notifier.execute(session, accountId, childIds);

        final state = container.read(deleteTrashSubfoldersProvider);
        expect(state, isA<DeleteTrashSubfoldersFailed>());
        expect((state as DeleteTrashSubfoldersFailed).exception, error);
      });

      test('transitions to Failed when interactor is not registered', () async {
        Get.reset();
        container.dispose();
        container = ProviderContainer();
        notifier = container.read(deleteTrashSubfoldersProvider.notifier);

        await notifier.execute(session, accountId, childIds);

        expect(container.read(deleteTrashSubfoldersProvider),
            isA<DeleteTrashSubfoldersFailed>());
      });
    });

    group('mounted guard', () {
      test('does not throw when provider is disposed during operation',
          () async {
        final completer = Future<void>.delayed(const Duration(milliseconds: 50));
        when(mockInteractor.execute(any, any, any)).thenAnswer(
          (_) async* {
            await completer;
            yield Right<Failure, Success>(
              DeleteMultipleMailboxAllSuccess(childIds),
            );
          },
        );

        // Start execute but don't await — dispose container mid-flight
        final call = notifier.execute(session, accountId, childIds);
        container.dispose();

        // Must not throw even though provider was disposed
        await expectLater(call, completes);
      });
    });
  });
}
