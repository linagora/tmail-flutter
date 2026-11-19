import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:tmail_ui_user/features/push_notification/domain/model/delegated_notification_baseline.dart';
import 'package:tmail_ui_user/features/push_notification/domain/repository/fcm_repository.dart';
import 'package:tmail_ui_user/features/push_notification/domain/state/store_delegated_notification_baselines_state.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_delegated_notification_baselines_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';

class _FakeFCMRepository implements FCMRepository {
  final Map<AccountId, Object?> stateOrErrorByAccount;
  final Object? storeError;
  final Set<AccountId> withCursor;
  final Object? cursorError;
  final List<AccountId> stateReads = [];
  List<DelegatedNotificationBaseline>? stored;

  _FakeFCMRepository(
    this.stateOrErrorByAccount, {
    this.storeError,
    this.withCursor = const {},
    this.cursorError,
  });

  @override
  Future<Set<AccountId>> getDelegatedAccountIdsWithNotificationCursor(Session session) async {
    if (cursorError != null) throw cursorError!;
    return withCursor;
  }

  @override
  Future<jmap.State?> getEmailState(Session session, AccountId accountId) async {
    stateReads.add(accountId);
    final stateOrError = stateOrErrorByAccount[accountId];
    if (stateOrError is Exception) throw stateOrError;
    return stateOrError as jmap.State?;
  }

  @override
  Future<void> storeDelegatedNotificationBaselines(
    Session session,
    List<DelegatedNotificationBaseline> baselines,
  ) async {
    if (storeError != null) throw storeError!;
    stored = baselines;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final session = DelegationFixtures.session();
  final bobState = jmap.State('bob-state');
  final carolState = jmap.State('carol-state');
  final ownerNames = {
    DelegationFixtures.bobAccountId: DelegationFixtures.bobAddress,
    DelegationFixtures.carolAccountId: DelegationFixtures.carolAddress,
  };

  test('stores the current Email state of every delegated mailbox with its owner', () async {
    final repository = _FakeFCMRepository({
      DelegationFixtures.bobAccountId: bobState,
      DelegationFixtures.carolAccountId: carolState,
    });

    final states = await StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, ownerNames)
        .toList();

    expect(states.last.getOrElse(() => throw 'failure'), isA<StoreDelegatedNotificationBaselinesSuccess>());
    expect(repository.stored, [
      DelegatedNotificationBaseline(
        accountId: DelegationFixtures.bobAccountId,
        state: bobState,
        ownerName: DelegationFixtures.bobAddress,
      ),
      DelegatedNotificationBaseline(
        accountId: DelegationFixtures.carolAccountId,
        state: carolState,
        ownerName: DelegationFixtures.carolAddress,
      ),
    ]);
  });

  test('keeps the other mailboxes when one state cannot be read, and fails so the caller retries', () async {
    final repository = _FakeFCMRepository({
      DelegationFixtures.bobAccountId: Exception('unreachable'),
      DelegationFixtures.carolAccountId: carolState,
    });

    final states = await StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, ownerNames)
        .toList();

    expect(repository.stored?.map((baseline) => baseline.accountId), [DelegationFixtures.carolAccountId]);
    expect(
      states.last.fold((failure) => failure, (success) => success),
      isA<StoreDelegatedNotificationBaselinesFailure>(),
    );
  });

  test('SHOULD NOT store a mailbox the server returns no state for, and fails so the caller retries', () async {
    final repository = _FakeFCMRepository({DelegationFixtures.carolAccountId: carolState});

    final states = await StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, ownerNames)
        .toList();

    expect(repository.stored?.map((baseline) => baseline.accountId), [DelegationFixtures.carolAccountId]);
    expect(
      states.last.fold((failure) => failure, (success) => success),
      isA<StoreDelegatedNotificationBaselinesFailure>(),
    );
  });

  test('keeps the stored cursor of a mailbox that already has one and SHOULD NOT read its state', () async {
    final repository = _FakeFCMRepository(
      {DelegationFixtures.carolAccountId: carolState},
      withCursor: {DelegationFixtures.bobAccountId},
    );

    final states = await StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, ownerNames)
        .toList();

    expect(states.last.getOrElse(() => throw 'failure'), isA<StoreDelegatedNotificationBaselinesSuccess>());
    expect(repository.stateReads, [DelegationFixtures.carolAccountId]);
    expect(repository.stored, [
      DelegatedNotificationBaseline(
        accountId: DelegationFixtures.bobAccountId,
        ownerName: DelegationFixtures.bobAddress,
      ),
      DelegatedNotificationBaseline(
        accountId: DelegationFixtures.carolAccountId,
        state: carolState,
        ownerName: DelegationFixtures.carolAddress,
      ),
    ]);
  });

  test('SHOULD NOT store anything when the stored cursors cannot be read', () async {
    final repository = _FakeFCMRepository(
      {DelegationFixtures.bobAccountId: bobState},
      cursorError: Exception('keychain locked'),
    );

    final states = await StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, ownerNames)
        .toList();

    expect(repository.stored, isNull);
    expect(
      states.last.fold((failure) => failure, (success) => success),
      isA<StoreDelegatedNotificationBaselinesFailure>(),
    );
  });

  test('stores an empty list when no delegated mailbox is notified', () async {
    final repository = _FakeFCMRepository({});

    await StoreDelegatedNotificationBaselinesInteractor(repository).execute(session, {}).drain<void>();

    expect(repository.stored, isEmpty);
  });

  test('emits a failure when the baselines cannot be stored', () async {
    final repository = _FakeFCMRepository(
      {DelegationFixtures.bobAccountId: bobState},
      storeError: Exception('keychain locked'),
    );

    final states = await StoreDelegatedNotificationBaselinesInteractor(repository)
        .execute(session, {DelegationFixtures.bobAccountId: DelegationFixtures.bobAddress})
        .toList();

    expect(
      states.last.fold((failure) => failure, (success) => success),
      isA<StoreDelegatedNotificationBaselinesFailure>(),
    );
  });
}
