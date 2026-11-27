import 'dart:async';

import 'package:delegation/model/delegate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/remove_delegate_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/remove_delegate_submission.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/remove_delegate_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';

import '../../../../fixtures/delegate_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';

Future<void> _untilRepositoryCalled() => Future<void>.delayed(Duration.zero);

void main() {
  final bob = Delegate(id: Id('bob-delegate'), username: DelegationFixtures.bobAddress);

  late ProviderContainer container;
  late FakeDelegateRepository repository;
  late Session session;

  RemoveDelegateNotifier notifier() => container.read(removeDelegateProvider.notifier);
  bool isRemoving() => container.read(removeDelegateProvider);

  setUp(() {
    repository = FakeDelegateRepository();
    session = DelegationFixtures.session();
    container = ProviderContainer(overrides: [
      delegateRepositoryProvider.overrideWithValue(repository),
    ]);
    container.listen(removeDelegateProvider, (_, __) {});
  });

  tearDown(() => container.dispose());

  test('should not be removing before a submit', () {
    expect(isRemoving(), isFalse);
  });

  test('should send one remove of the delegate on my account and mark it removing', () async {
    unawaited(notifier().submit(session, bob));
    await _untilRepositoryCalled();

    expect(repository.removeCalls, [(session.accountId, bob)]);
    expect(isRemoving(), isTrue);
  });

  test('should send only one request on a repeat tap', () async {
    final first = notifier().submit(session, bob);
    final repeat = await notifier().submit(session, bob);
    await _untilRepositoryCalled();
    repository.pendingRemoves.single.complete(RemoveDelegateResult(removedDelegate: bob, delegates: const []));
    await first;

    expect(repeat, isA<RemoveDelegateIgnored>());
    expect(repository.removeCalls, hasLength(1));
  });

  test('should return the result and stop removing when the delegate is removed', () async {
    final submit = notifier().submit(session, bob);
    await _untilRepositoryCalled();
    final expected = RemoveDelegateResult(removedDelegate: bob, delegates: const []);
    repository.pendingRemoves.last.complete(expected);

    expect(await submit, isA<RemoveDelegateSucceeded>().having((done) => done.result, 'result', expected));
    expect(isRemoving(), isFalse);
  });

  test('should report a failure and stop removing when the request fails', () async {
    final submit = notifier().submit(session, bob);
    await _untilRepositoryCalled();
    repository.pendingRemoves.last.completeError(Exception('boom'));

    expect(await submit, isA<RemoveDelegateFailed>());
    expect(isRemoving(), isFalse);
  });

  test('should allow a new submit after a failure', () async {
    final failed = notifier().submit(session, bob);
    await _untilRepositoryCalled();
    repository.pendingRemoves.last.completeError(Exception('boom'));
    await failed;

    unawaited(notifier().submit(session, bob));
    await _untilRepositoryCalled();

    expect(repository.removeCalls, hasLength(2));
  });

  test('should still return the result when the provider is disposed meanwhile', () async {
    final submit = notifier().submit(session, bob);
    await _untilRepositoryCalled();
    container.dispose();
    final expected = RemoveDelegateResult(removedDelegate: bob);
    repository.pendingRemoves.last.complete(expected);

    expect(await submit, isA<RemoveDelegateSucceeded>().having((done) => done.result, 'result', expected));
  });
}
