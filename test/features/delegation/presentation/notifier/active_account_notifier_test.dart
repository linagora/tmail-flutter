import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  ActiveAccountNotifier notifierOf() => container.read(activeAccountProvider.notifier);
  ActiveAccount? stateOf() => container.read(activeAccountProvider);

  test('build() starts with no account before a session is applied', () {
    expect(stateOf(), isNull);
  });

  group('applySession', () {
    test('starts on my own account', () {
      final session = DelegationFixtures.session();

      notifierOf().applySession(session);

      expect(stateOf(), ActiveAccount.personal(session));
    });

    test('keeps the shown delegated account while the new session still lists it', () {
      notifierOf().applySession(DelegationFixtures.session());
      notifierOf().select(DelegationFixtures.bobAccountId);
      final reReadSession = DelegationFixtures.session(state: 'state-2');

      notifierOf().applySession(reReadSession);

      expect(stateOf(), ActiveAccount.delegated(reReadSession, DelegationFixtures.bobAccountId));
    });

    test('goes back to my own account when the new session no longer lists the shown delegated account', () {
      notifierOf().applySession(DelegationFixtures.session());
      notifierOf().select(DelegationFixtures.bobAccountId);
      final sessionWithoutBob = DelegationFixtures.session(listsBob: false);

      notifierOf().applySession(sessionWithoutBob);

      expect(stateOf(), ActiveAccount.personal(sessionWithoutBob));
    });

    test('starts on my own account when another user signs in, even if the account is listed', () {
      notifierOf().applySession(DelegationFixtures.session());
      notifierOf().select(DelegationFixtures.bobAccountId);
      final otherUserSession = DelegationFixtures.session(username: DelegationFixtures.carolAddress);

      notifierOf().applySession(otherUserSession);

      expect(stateOf(), ActiveAccount.personal(otherUserSession));
    });

    test(
      'same user signing in after logout starts on mine, not the previous delegated account',
      () {
        notifierOf().applySession(DelegationFixtures.session());
        notifierOf().select(DelegationFixtures.bobAccountId);

        notifierOf().clear();
        final signInSession = DelegationFixtures.session(state: 'state-2');
        notifierOf().applySession(signInSession);

        expect(stateOf(), ActiveAccount.personal(signInSession));
      },
    );

    test('stays on my own account when it was shown', () {
      notifierOf().applySession(DelegationFixtures.session());
      final reReadSession = DelegationFixtures.session(state: 'state-2');

      notifierOf().applySession(reReadSession);

      expect(stateOf(), ActiveAccount.personal(reReadSession));
    });
  });

  group('canSelect', () {
    test('accepts my own account and a delegated account listed by the session, without changing the shown account', () {
      final session = DelegationFixtures.session();
      notifierOf().applySession(session);

      expect(notifierOf().canSelect(DelegationFixtures.aliceAccountId), isTrue);
      expect(notifierOf().canSelect(DelegationFixtures.bobAccountId), isTrue);
      expect(stateOf(), ActiveAccount.personal(session));
    });

    test('refuses an account the session does not list', () {
      notifierOf().applySession(DelegationFixtures.session(listsBob: false));

      expect(notifierOf().canSelect(DelegationFixtures.bobAccountId), isFalse);
      expect(notifierOf().canSelect(DelegationFixtures.unknownAccountId), isFalse);
    });

    test('refuses any account before a session is applied', () {
      expect(notifierOf().canSelect(DelegationFixtures.aliceAccountId), isFalse);
    });
  });

  group('select', () {
    test('shows a delegated account listed by the session', () {
      final session = DelegationFixtures.session();
      notifierOf().applySession(session);

      final selected = notifierOf().select(DelegationFixtures.carolAccountId);

      expect(selected, isTrue);
      expect(stateOf(), ActiveAccount.delegated(session, DelegationFixtures.carolAccountId));
    });

    test('shows my own account again', () {
      final session = DelegationFixtures.session();
      notifierOf().applySession(session);
      notifierOf().select(DelegationFixtures.bobAccountId);

      final selected = notifierOf().select(DelegationFixtures.aliceAccountId);

      expect(selected, isTrue);
      expect(stateOf(), ActiveAccount.personal(session));
    });

    test('refuses an account the session does not list and keeps the shown account', () {
      final session = DelegationFixtures.session();
      notifierOf().applySession(session);
      notifierOf().select(DelegationFixtures.bobAccountId);

      final selected = notifierOf().select(DelegationFixtures.unknownAccountId);

      expect(selected, isFalse);
      expect(stateOf(), ActiveAccount.delegated(session, DelegationFixtures.bobAccountId));
    });

    test('refuses any account before a session is applied', () {
      final selected = notifierOf().select(DelegationFixtures.aliceAccountId);

      expect(selected, isFalse);
      expect(stateOf(), isNull);
    });
  });

  group('selectPersonal', () {
    test('shows my own account', () {
      final session = DelegationFixtures.session();
      notifierOf().applySession(session);
      notifierOf().select(DelegationFixtures.bobAccountId);

      notifierOf().selectPersonal();

      expect(stateOf(), ActiveAccount.personal(session));
    });

    test('does nothing before a session is applied', () {
      notifierOf().selectPersonal();

      expect(stateOf(), isNull);
    });
  });
}
