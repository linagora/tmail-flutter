import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_bridge.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_reader.dart';

import '../../../../fixtures/active_account_bridge_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';

class _Reader with ActiveAccountReader {}

void main() {
  tearDown(() => Get.delete<ActiveAccountBridge>(force: true));

  test('reads the shown account of the registered bridge', _readsShownAccount);
  test('follows a switch made after the reader was created', _followsLaterSwitch);
  test('a worker registered after the dashboard set my account loads the shown account at once',
      _loadsAtOnceWhenMyAccountIsSet);
  test('a worker registered before the dashboard set my account waits for it', _waitsForMyAccount);
}

void _readsShownAccount() {
  ActiveAccountBridgeFixtures.put(
    DelegationFixtures.session(),
    shownAccountId: DelegationFixtures.bobAccountId,
  );

  expect(_Reader().activeAccountId, DelegationFixtures.bobAccountId);
}

void _followsLaterSwitch() {
  final reader = _Reader();
  final bridge = ActiveAccountBridgeFixtures.put(DelegationFixtures.session());
  expect(reader.activeAccountId, DelegationFixtures.aliceAccountId);

  bridge.accountId.value = DelegationFixtures.carolAccountId;

  expect(reader.activeAccountId, DelegationFixtures.carolAccountId);
}

void _loadsAtOnceWhenMyAccountIsSet() {
  ActiveAccountBridgeFixtures.put(DelegationFixtures.session(), shownAccountId: DelegationFixtures.bobAccountId);
  final shownAccountIds = <AccountId>[];

  final worker = _Reader().everShownAccount(Rxn(DelegationFixtures.aliceAccountId), shownAccountIds.add);
  addTearDown(worker.dispose);

  expect(shownAccountIds, [DelegationFixtures.bobAccountId]);
}

void _waitsForMyAccount() {
  ActiveAccountBridgeFixtures.put(DelegationFixtures.session(), shownAccountId: DelegationFixtures.bobAccountId);
  final personalAccountId = Rxn<AccountId>();
  final shownAccountIds = <AccountId>[];
  final worker = _Reader().everShownAccount(personalAccountId, shownAccountIds.add);
  addTearDown(worker.dispose);
  expect(shownAccountIds, isEmpty);

  personalAccountId.value = DelegationFixtures.aliceAccountId;

  expect(shownAccountIds, [DelegationFixtures.bobAccountId]);
}
