import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/riverpod_active_account_source.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  late ProviderContainer container;
  late RiverpodActiveAccountSource source;

  setUp(() {
    container = ProviderContainer();
    source = RiverpodActiveAccountSource(container);
  });

  tearDown(() => container.dispose());

  void select(AccountId accountId) => container.read(activeAccountProvider.notifier).select(accountId);

  List<AccountId> watchShownAccounts() {
    final shownAccountIds = <AccountId>[];
    addTearDown(source.watchShown(shownAccountIds.add));
    return shownAccountIds;
  }

  group('reads:', () {
    test('has no account before a session is applied', () {
      expect(source.activeAccount, isNull);
      expect(source.accountId, isNull);
    });

    test('shows my own account once a session is applied', () {
      final session = DelegationFixtures.session();

      source.applySession(session);

      expect(source.activeAccount, ActiveAccount.personal(session));
      expect(source.accountId, DelegationFixtures.aliceAccountId);
    });

    test('reads the account shown through the provider, keeping no copy of its own', () {
      source.applySession(DelegationFixtures.session());

      select(DelegationFixtures.bobAccountId);

      expect(source.accountId, DelegationFixtures.bobAccountId);
      expect(source.activeAccount!.isDelegated, isTrue);
    });

    test('clear forgets the shown account', () {
      source.applySession(DelegationFixtures.session());
      select(DelegationFixtures.bobAccountId);

      source.clear();

      expect(source.activeAccount, isNull);
      expect(container.read(activeAccountProvider), isNull);
    });

    test('clear tells the listeners of the shown account even when nothing reads it afterwards', () async {
      source.applySession(DelegationFixtures.session());
      final shownAccounts = <ActiveAccount?>[];
      container.listen<ActiveAccount?>(activeAccountProvider, (_, next) => shownAccounts.add(next));

      source.clear();
      await container.pump();

      expect(shownAccounts, [null]);
    });
  });

  group('watchShown:', () {
    test('calls back at once with an account already shown', () {
      source.applySession(DelegationFixtures.session());
      select(DelegationFixtures.bobAccountId);

      expect(watchShownAccounts(), [DelegationFixtures.bobAccountId]);
    });

    test('does not call back while no account is shown', () {
      expect(watchShownAccounts(), isEmpty);
    });

    test('calls back once a session is applied, then on each switch', () {
      final shownAccountIds = watchShownAccounts();

      source.applySession(DelegationFixtures.session());
      select(DelegationFixtures.bobAccountId);
      select(DelegationFixtures.carolAccountId);

      expect(shownAccountIds, [
        DelegationFixtures.aliceAccountId,
        DelegationFixtures.bobAccountId,
        DelegationFixtures.carolAccountId,
      ]);
    });

    test('does not call back on a session re-read of the same account', () {
      source.applySession(DelegationFixtures.session());
      final shownAccountIds = watchShownAccounts()..clear();

      source.applySession(DelegationFixtures.session(state: 'state-2'));

      expect(shownAccountIds, isEmpty);
      expect(source.activeAccount!.session.state.value, 'state-2');
    });

    test('does not call back when the shown account is cleared', () async {
      source.applySession(DelegationFixtures.session());
      final shownAccountIds = watchShownAccounts()..clear();

      source.clear();
      await container.pump();

      expect(shownAccountIds, isEmpty);
    });

    test('calls back again for the same account once it was cleared and applied again', () {
      source.applySession(DelegationFixtures.session());
      final shownAccountIds = watchShownAccounts()..clear();

      source
        ..clear()
        ..applySession(DelegationFixtures.session());

      expect(shownAccountIds, [DelegationFixtures.aliceAccountId]);
    });

    test('stops calling back once cancelled', () {
      source.applySession(DelegationFixtures.session());
      final shownAccountIds = <AccountId>[];
      final cancel = source.watchShown(shownAccountIds.add);
      shownAccountIds.clear();

      cancel();
      select(DelegationFixtures.bobAccountId);

      expect(shownAccountIds, isEmpty);
    });
  });

  group('switch attempts:', () {
    test('a request stamped while another account is shown outside a switch stays current', () {
      source.applySession(DelegationFixtures.session());
      final stampedAttemptIds = <int>[];
      addTearDown(source.watchShown((_) => stampedAttemptIds.add(source.currentSwitchAttemptId)));

      select(DelegationFixtures.bobAccountId);

      expect(stampedAttemptIds.last, source.currentSwitchAttemptId);
    });

    test('a request stamped in a watch registered before the first session stays current', () {
      final stampedAttemptIds = <int>[];
      addTearDown(source.watchShown((_) => stampedAttemptIds.add(source.currentSwitchAttemptId)));
      source.applySession(DelegationFixtures.session());

      select(DelegationFixtures.bobAccountId);

      expect(stampedAttemptIds.last, source.currentSwitchAttemptId);
    });

    test('another account shown outside a switch starts a new attempt', () {
      source.applySession(DelegationFixtures.session());
      final attemptBefore = source.currentSwitchAttemptId;

      select(DelegationFixtures.bobAccountId);

      expect(source.currentSwitchAttemptId, attemptBefore + 1);
    });

    test('a session re-read of the same account keeps the attempt', () {
      source.applySession(DelegationFixtures.session());
      final attemptBefore = source.currentSwitchAttemptId;

      source.applySession(DelegationFixtures.session(state: 'state-2'));

      expect(source.currentSwitchAttemptId, attemptBefore);
    });
  });
}
