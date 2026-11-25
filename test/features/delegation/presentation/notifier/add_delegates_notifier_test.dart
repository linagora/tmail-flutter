import 'dart:async';

import 'package:delegation/model/delegate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/add_delegates_result.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/add_delegates_form.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/add_delegates_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegate_providers.dart';

import '../../../../fixtures/delegate_fakes.dart';
import '../../../../fixtures/delegation_fixtures.dart';

Future<void> _untilRepositoryCalled() => Future<void>.delayed(Duration.zero);

void main() {
  const daveAddress = 'dave@domain.tld';

  late ProviderContainer container;
  late FakeDelegateRepository repository;
  late Session session;

  AddDelegatesNotifier notifier() => container.read(addDelegatesProvider.notifier);
  AddDelegatesForm form() => container.read(addDelegatesProvider);

  DelegateAddressRefusal? pick(String address, {Set<String> delegates = const {}}) => notifier().pick(
        EmailAddress(null, address),
        ownUsername: DelegationFixtures.aliceAddress,
        delegateUsernames: delegates,
      );

  Future<AddDelegatesSubmission> submitWith(AddDelegatesResult Function() reply) async {
    final submit = notifier().submit(session);
    await _untilRepositoryCalled();
    repository.pendingAdds.last.complete(reply());
    return submit;
  }

  setUp(() {
    repository = FakeDelegateRepository();
    session = DelegationFixtures.session();
    container = ProviderContainer(overrides: [
      delegateRepositoryProvider.overrideWithValue(repository),
    ]);
    container.listen(addDelegatesProvider, (_, __) {});
  });

  tearDown(() => container.dispose());

  group('pick', () {
    test('should add a trimmed chip for a valid address', () {
      expect(pick('  ${DelegationFixtures.bobAddress} '), isNull);

      expect(form().candidates, [DelegateCandidate(EmailAddress(null, DelegationFixtures.bobAddress))]);
    });

    test('should keep the typed case of an address', () {
      pick('Bob@Domain.tld');

      expect(form().candidates.single.username, 'Bob@Domain.tld');
    });

    test('should keep the contact name of a picked suggestion', () {
      notifier().pick(
        EmailAddress('Bob', DelegationFixtures.bobAddress),
        ownUsername: DelegationFixtures.aliceAddress,
        delegateUsernames: const {},
      );

      expect(form().candidates.single.emailAddress, EmailAddress('Bob', DelegationFixtures.bobAddress));
    });

    test('should accept a localhost address', () {
      expect(pick('bob@localhost'), isNull);
    });

    test('should refuse an invalid address', () {
      expect(pick('not-an-address'), DelegateAddressRefusal.invalid);
      expect(form().candidates, isEmpty);
    });

    test('should refuse my own address whatever its case', () {
      expect(pick('ALICE@domain.tld'), DelegateAddressRefusal.yourself);
      expect(form().candidates, isEmpty);
    });

    test('should refuse my own address when the session username is not lowercase', () {
      final refusal = notifier().pick(
        EmailAddress(null, DelegationFixtures.aliceAddress),
        ownUsername: DelegationFixtures.aliceAddress.toUpperCase(),
        delegateUsernames: const {},
      );

      expect(refusal, DelegateAddressRefusal.yourself);
    });

    test('should refuse an existing delegate whatever its case', () {
      expect(
        pick('Bob@Domain.tld', delegates: {DelegationFixtures.bobAddress}),
        DelegateAddressRefusal.alreadyDelegate,
      );
      expect(form().candidates, isEmpty);
    });

    test('should refuse an address already picked whatever its case', () {
      pick(DelegationFixtures.bobAddress);

      expect(pick('BOB@domain.tld'), DelegateAddressRefusal.alreadyPicked);
      expect(form().candidates, hasLength(1));
    });
  });

  group('unpick', () {
    test('should remove the chip', () {
      pick(DelegationFixtures.bobAddress);
      pick(DelegationFixtures.carolAddress);

      notifier().unpick(form().candidates.first);

      expect(form().candidates.map((candidate) => candidate.username), [DelegationFixtures.carolAddress]);
    });

    test('should not remove a chip while submitting', () async {
      pick(DelegationFixtures.bobAddress);
      notifier().next();
      unawaited(notifier().submit(session));

      notifier().unpick(form().candidates.single);

      expect(form().candidates, hasLength(1));
    });
  });

  group('next and back', () {
    test('should not go next without a chip', () {
      notifier().next();

      expect(form().step, AddDelegatesStep.pick);
    });

    test('should go to confirm and back to pick', () {
      pick(DelegationFixtures.bobAddress);

      notifier().next();
      expect(form().step, AddDelegatesStep.confirm);

      notifier().back();
      expect(form().step, AddDelegatesStep.pick);
    });

    test('should not go back while submitting', () {
      pick(DelegationFixtures.bobAddress);
      notifier().next();
      unawaited(notifier().submit(session));

      notifier().back();

      expect(form().step, AddDelegatesStep.confirm);
    });
  });

  group('submit', () {
    setUp(() {
      pick(DelegationFixtures.bobAddress);
      pick(DelegationFixtures.carolAddress);
      notifier().next();
    });

    test('should send one request with every chip and mark the form submitting', () async {
      unawaited(notifier().submit(session));
      await _untilRepositoryCalled();

      expect(repository.addCalls, [
        {DelegationFixtures.bobAddress, DelegationFixtures.carolAddress},
      ]);
      expect(form().isSubmitting, isTrue);
    });

    test('should send only one request on a repeat tap', () async {
      final first = notifier().submit(session);
      final repeat = await notifier().submit(session);
      await _untilRepositoryCalled();
      repository.pendingAdds.single.complete(AddDelegatesResult(
        addedUsernames: [DelegationFixtures.bobAddress, DelegationFixtures.carolAddress],
        rejectedUsernames: const {},
      ));
      await first;

      expect(repeat, isA<AddDelegatesIgnored>());
      expect(repository.addCalls, hasLength(1));
    });

    test('should keep the confirm list when every address is added', () async {
      final expected = AddDelegatesResult(
        addedUsernames: [DelegationFixtures.bobAddress, DelegationFixtures.carolAddress],
        rejectedUsernames: const {},
        delegates: [Delegate(id: Id('bob-delegate'), username: DelegationFixtures.bobAddress)],
      );

      final result = await submitWith(() => expected);

      expect(result, isA<AddDelegatesSucceeded>().having((done) => done.result, 'result', expected));
      expect(form(), AddDelegatesForm(
        candidates: [
          DelegateCandidate(EmailAddress(null, DelegationFixtures.bobAddress)),
          DelegateCandidate(EmailAddress(null, DelegationFixtures.carolAddress)),
        ],
        step: AddDelegatesStep.confirm,
      ));
    });

    test('should keep only the rejected chips, marked, back on the pick step', () async {
      final result = await submitWith(() => AddDelegatesResult(
            addedUsernames: [DelegationFixtures.bobAddress],
            rejectedUsernames: {DelegationFixtures.carolAddress: SetError(SetError.invalidArguments)},
          ));

      expect((result as AddDelegatesSucceeded).result.addedUsernames, [DelegationFixtures.bobAddress]);
      expect(form(), AddDelegatesForm(
        candidates: [DelegateCandidate(EmailAddress(null, DelegationFixtures.carolAddress), isRejected: true)],
      ));
      expect(form().canGoNext, isFalse);
    });

    test('should allow next again once the rejected chips are removed and a new one is picked', () async {
      await submitWith(() => AddDelegatesResult(
            addedUsernames: const [],
            rejectedUsernames: {DelegationFixtures.carolAddress: null, DelegationFixtures.bobAddress: null},
          ));

      for (final candidate in [...form().candidates]) {
        notifier().unpick(candidate);
      }
      pick(daveAddress);

      expect(form().canGoNext, isTrue);
    });

    test('should keep every chip on confirm and report a failure when the request fails', () async {
      final submit = notifier().submit(session);
      await _untilRepositoryCalled();
      repository.pendingAdds.last.completeError(Exception('boom'));

      expect(await submit, isA<AddDelegatesFailed>());
      expect(form().isSubmitting, isFalse);
      expect(form().step, AddDelegatesStep.confirm);
      expect(form().candidates.map((candidate) => candidate.username),
          [DelegationFixtures.bobAddress, DelegationFixtures.carolAddress]);
    });

    test('should still return the result when the provider is disposed meanwhile', () async {
      final submit = notifier().submit(session);
      await _untilRepositoryCalled();
      container.dispose();
      final expected = AddDelegatesResult(
        addedUsernames: [DelegationFixtures.bobAddress, DelegationFixtures.carolAddress],
        rejectedUsernames: const {},
      );
      repository.pendingAdds.last.complete(expected);

      expect(await submit, isA<AddDelegatesSucceeded>().having((done) => done.result, 'result', expected));
    });
  });
}
