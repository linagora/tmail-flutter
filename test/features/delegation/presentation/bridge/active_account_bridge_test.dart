import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_bridge.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  late ProviderContainer container;
  late ActiveAccountBridge bridge;

  setUp(() {
    container = ProviderContainer();
    bridge = ActiveAccountBridge(container);
  });

  tearDown(() {
    bridge.onClose();
    container.dispose();
  });

  test('has no account before a session is applied', () {
    expect(bridge.activeAccount, isNull);
    expect(bridge.accountId.value, isNull);
  });

  test('shows my own account once a session is applied', () {
    final session = DelegationFixtures.session();

    bridge.applySession(session);

    expect(bridge.activeAccount, ActiveAccount.personal(session));
    expect(bridge.accountId.value, DelegationFixtures.aliceAccountId);
  });

  test('follows the shown account when it changes outside the bridge', () {
    bridge.applySession(DelegationFixtures.session());

    container.read(activeAccountProvider.notifier).select(DelegationFixtures.bobAccountId);

    expect(bridge.accountId.value, DelegationFixtures.bobAccountId);
  });

  test('starts from an account already shown when it is created', () {
    final session = DelegationFixtures.session();
    final otherContainer = ProviderContainer();
    addTearDown(otherContainer.dispose);
    otherContainer.read(activeAccountProvider.notifier)
      ..applySession(session)
      ..select(DelegationFixtures.bobAccountId);

    final otherBridge = ActiveAccountBridge(otherContainer);
    addTearDown(otherBridge.onClose);

    expect(otherBridge.accountId.value, DelegationFixtures.bobAccountId);
  });

  test('does not notify the account id again on a session re-read of the same account', () {
    bridge.applySession(DelegationFixtures.session());
    final notified = <AccountId?>[];
    bridge.accountId.listen(notified.add);

    bridge.applySession(DelegationFixtures.session(state: 'state-2'));

    expect(notified, isEmpty);
    expect(bridge.activeAccount!.session.state.value, 'state-2');
  });

  test('clear forgets the shown account, so a new bridge does not start from it', () {
    bridge.applySession(DelegationFixtures.session());
    container.read(activeAccountProvider.notifier).select(DelegationFixtures.bobAccountId);

    bridge.clear();
    final nextBridge = ActiveAccountBridge(container);
    addTearDown(nextBridge.onClose);

    expect(bridge.accountId.value, isNull);
    expect(nextBridge.accountId.value, isNull);
  });

  test('stops following the shown account once closed', () {
    bridge.applySession(DelegationFixtures.session());
    bridge.onClose();

    container.read(activeAccountProvider.notifier).select(DelegationFixtures.bobAccountId);

    expect(bridge.accountId.value, DelegationFixtures.aliceAccountId);
  });
}
