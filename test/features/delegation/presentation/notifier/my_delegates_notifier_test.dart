import 'dart:async';

import 'package:delegation/model/delegate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/my_delegates_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';

import '../../../../fixtures/delegate_fakes.dart';
import '../../../../fixtures/delegated_to_me_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';

typedef FinishRead = void Function(Completer<List<Delegate>> read);

void main() {
  final bob = Delegate(id: Id('bob-delegate'), username: DelegationFixtures.bobAddress);
  final carol = Delegate(id: Id('carol-delegate'), username: DelegationFixtures.carolAddress);

  late ProviderContainer container;
  late FakeDelegateRepository repository;
  late Session session;

  MyDelegatesNotifier notifier() => container.read(myDelegatesProvider.notifier);
  AsyncValue<List<Delegate>> stateOf() => container.read(myDelegatesProvider);

  setUp(() {
    repository = FakeDelegateRepository();
    session = DelegationFixtures.session();
    container = ProviderContainer(overrides: [
      delegateRepositoryProvider.overrideWithValue(repository),
    ]);
    container.listen(myDelegatesProvider, (_, __) {});
  });

  tearDown(() => container.dispose());

  group('load', () {
    test('should be loading before the first read', () {
      expect(stateOf(), isA<AsyncLoading<List<Delegate>>>());
    });

    test('should read the delegates of the signed-in account', () async {
      final load = notifier().load(session);
      await untilRepositoryCalled();

      expect(repository.getCalls, [DelegationFixtures.aliceAccountId]);
      repository.pendingGets.single.complete([bob, carol]);
      await load;

      expect(stateOf().value, [bob, carol]);
    });

    test('should give an empty list when no one has access', () async {
      final load = notifier().load(session);
      await untilRepositoryCalled();
      repository.pendingGets.single.complete([]);
      await load;

      expect(stateOf(), isA<AsyncData<List<Delegate>>>());
      expect(stateOf().value, isEmpty);
    });

    test('should show an error when the read fails', () async {
      final load = notifier().load(session);
      await untilRepositoryCalled();
      repository.pendingGets.single.completeError(Exception('boom'));
      await load;

      expect(stateOf(), isA<AsyncError<List<Delegate>>>());
    });

    test('should go back to loading and then list on retry after a failure', () async {
      final failed = notifier().load(session);
      await untilRepositoryCalled();
      repository.pendingGets.single.completeError(Exception('boom'));
      await failed;

      final retry = notifier().load(session);
      expect(stateOf(), isA<AsyncLoading<List<Delegate>>>());
      await untilRepositoryCalled();
      repository.pendingGets.last.complete([bob]);
      await retry;

      expect(stateOf().value, [bob]);
    });

    for (final (outcome, finishFirstRead) in <(String, FinishRead)>[
      ('list', (read) => read.complete([bob])),
      ('failure', (read) => read.completeError(Exception('boom'))),
    ]) {
      test('should not let a slow earlier $outcome overwrite a newer list', () async {
        final first = notifier().load(session);
        await untilRepositoryCalled();
        final second = notifier().load(session);
        await untilRepositoryCalled();

        repository.pendingGets.last.complete([carol]);
        await second;
        finishFirstRead(repository.pendingGets.first);
        await first;

        expect(stateOf().value, [carol]);
      });
    }

    test('should keep the current list while reading it again', () async {
      final first = notifier().load(session);
      await untilRepositoryCalled();
      repository.pendingGets.single.complete([bob]);
      await first;

      final reload = notifier().load(session);
      await untilRepositoryCalled();
      expect(stateOf(), isA<AsyncData<List<Delegate>>>());
      expect(stateOf().value, [bob]);

      repository.pendingGets.last.complete([bob, carol]);
      await reload;
      expect(stateOf().value, [bob, carol]);
    });

    test('should drop a read that finishes after dispose', () async {
      final load = notifier().load(session);
      await untilRepositoryCalled();
      container.dispose();

      repository.pendingGets.single.complete([bob]);
      await expectLater(load, completes);
    });

    test('should drop a read that finishes after the By me tab stops listening', () async {
      final tabContainer = ProviderContainer(overrides: [
        delegateRepositoryProvider.overrideWithValue(repository),
      ]);
      addTearDown(tabContainer.dispose);
      final tab = tabContainer.listen(myDelegatesProvider, (_, __) {});
      final load = tabContainer.read(myDelegatesProvider.notifier).load(session);
      await untilRepositoryCalled();

      tab.close();
      await tabContainer.pump();
      expect(tabContainer.exists(myDelegatesProvider), isFalse);

      repository.pendingGets.single.complete([bob]);
      await expectLater(load, completes);
    });
  });
}
