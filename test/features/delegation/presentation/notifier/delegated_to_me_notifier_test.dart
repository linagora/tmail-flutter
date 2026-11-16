import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:delegation/model/delegated_account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/delegated_to_me_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegated_account_providers.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';

import '../../../../fixtures/delegation_fixtures.dart';
import '../../../../fixtures/delegated_to_me_fakes.dart';

void main() {
  final bobDelegation = DelegatedAccount(id: Id('bob-delegation'), username: DelegationFixtures.bobAddress);
  final carolDelegation = DelegatedAccount(id: Id('carol-delegation'), username: DelegationFixtures.carolAddress);

  late ProviderContainer container;
  late FakeDelegatedAccountRepository repository;
  late FakeGetSessionInteractor getSessionInteractor;
  late Session session;

  DelegatedToMeNotifier notifier() => container.read(delegatedToMeProvider.notifier);
  AsyncValue<List<DelegatedAccount>> stateOf() => container.read(delegatedToMeProvider);

  Future<void> loadWith(List<DelegatedAccount> accounts) async {
    final load = notifier().load(session);
    await untilRepositoryCalled();
    repository.pendingLoads.last.complete(accounts);
    await load;
  }

  setUp(() {
    repository = FakeDelegatedAccountRepository();
    getSessionInteractor = FakeGetSessionInteractor();
    Get.put<GetSessionInteractor>(getSessionInteractor);
    session = DelegationFixtures.session();
    container = ProviderContainer(overrides: [
      delegatedAccountRepositoryProvider.overrideWithValue(repository),
    ]);
    container.listen(delegatedToMeProvider, (_, __) {});
    container.read(activeAccountProvider.notifier).applySession(session);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  group('load', () {
    test('should list the delegated accounts on success', () async {
      await loadWith([bobDelegation, carolDelegation]);

      expect(stateOf().value, [bobDelegation, carolDelegation]);
    });

    test('should expose an error when the server call fails', () async {
      final load = notifier().load(session);
      await untilRepositoryCalled();
      repository.pendingLoads.last.completeError(Exception('boom'));
      await load;

      expect(stateOf().hasError, isTrue);
    });

    test('should not let an older load overwrite a newer one', () async {
      final firstLoad = notifier().load(session);
      final secondLoad = notifier().load(session);
      await untilRepositoryCalled();
      repository.pendingLoads[1].complete([carolDelegation]);
      await secondLoad;
      repository.pendingLoads[0].complete([bobDelegation]);
      await firstLoad;

      expect(stateOf().value, [carolDelegation]);
    });
  });

  group('remove', () {
    test('should drop the account and apply the fresh session to the switcher', () async {
      await loadWith([bobDelegation, carolDelegation]);
      final freshSession = DelegationFixtures.session(state: 'state-2', listsBob: false);
      getSessionInteractor.result = Right(GetSessionSuccess(freshSession));

      final reloadedSessions = <Session>[];

      final removed = await notifier().remove(session, bobDelegation, onSessionReloaded: reloadedSessions.add);

      expect(removed, isTrue);
      expect(repository.removedIds, [bobDelegation.id]);
      expect(stateOf().value, [carolDelegation]);
      expect(container.read(activeAccountProvider)?.session, freshSession);
      expect(reloadedSessions, [freshSession]);
    });

    test('should not apply a cached session that still lists the removed mailbox', () async {
      await loadWith([bobDelegation]);
      getSessionInteractor.result = Right(GetSessionSuccess(
        DelegationFixtures.session(state: 'state-cached'),
        fromCache: true,
      ));

      final reloadedSessions = <Session>[];

      await notifier().remove(session, bobDelegation, onSessionReloaded: reloadedSessions.add);

      expect(container.read(activeAccountProvider)?.session, session);
      expect(reloadedSessions, isEmpty);
    });

    test('should report the removal and keep the session when the session re-read fails', () async {
      await loadWith([bobDelegation]);
      getSessionInteractor.result = Left(GetSessionFailure(Exception('boom')));
      final reloadedSessions = <Session>[];

      final removed = await notifier().remove(session, bobDelegation, onSessionReloaded: reloadedSessions.add);

      expect(removed, isTrue);
      expect(stateOf().value, isEmpty);
      expect(getSessionInteractor.calls, 1);
      expect(container.read(activeAccountProvider)?.session, session);
      expect(reloadedSessions, isEmpty);
    });

    test('should send one removal when the same mailbox is removed again while the first runs', () async {
      await loadWith([bobDelegation]);
      getSessionInteractor.result = Right(GetSessionSuccess(DelegationFixtures.session(listsBob: false)));
      repository.removeGate = Completer<void>();

      final firstRemoval = notifier().remove(session, bobDelegation);
      await untilRepositoryCalled();
      final secondRemoved = await notifier().remove(session, bobDelegation);
      repository.removeGate!.complete();

      expect(secondRemoved, isTrue);
      expect(await firstRemoval, isTrue);
      expect(repository.removedIds, [bobDelegation.id]);
    });

    test('should send a removal again once the earlier one failed', () async {
      await loadWith([bobDelegation]);
      repository.removeError = Exception('boom');
      await notifier().remove(session, bobDelegation);
      repository.removeError = null;
      getSessionInteractor.result = Right(GetSessionSuccess(DelegationFixtures.session(listsBob: false)));

      final removed = await notifier().remove(session, bobDelegation);

      expect(removed, isTrue);
      expect(repository.removedIds, [bobDelegation.id]);
    });

    test('should keep the list and the session when the removal fails', () async {
      await loadWith([bobDelegation]);
      repository.removeError = Exception('boom');

      final removed = await notifier().remove(session, bobDelegation);

      expect(removed, isFalse);
      expect(stateOf().value, [bobDelegation]);
      expect(getSessionInteractor.calls, 0);
      expect(container.read(activeAccountProvider)?.session, session);
    });
  });
}
