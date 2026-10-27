import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_reader.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';

import '../../../../fixtures/active_account_source_fixtures.dart';
import '../../../../fixtures/delegation_fixtures.dart';

class _Reader with ActiveAccountReader {}

void main() {
  tearDown(ActiveAccountSourceFixtures.unregister);

  test('reads the shown account of the registered source', () {
    ActiveAccountSourceFixtures.put(
      DelegationFixtures.session(),
      shownAccountId: DelegationFixtures.bobAccountId,
    );

    expect(_Reader().activeAccountId, DelegationFixtures.bobAccountId);
  });

  test('follows a switch made after the reader was created', () {
    final reader = _Reader();
    final container = ActiveAccountSourceFixtures.newContainer();
    ActiveAccountSourceFixtures.put(DelegationFixtures.session(), container: container);
    expect(reader.activeAccountId, DelegationFixtures.aliceAccountId);

    container.read(activeAccountProvider.notifier).select(DelegationFixtures.carolAccountId);

    expect(reader.activeAccountId, DelegationFixtures.carolAccountId);
  });

  test('reads the source registered at the time of the read', () {
    final reader = _Reader();
    ActiveAccountSourceFixtures.put(DelegationFixtures.session());

    ActiveAccountSourceFixtures.putShowing(DelegationFixtures.bobAccountId);

    expect(reader.activeAccountId, DelegationFixtures.bobAccountId);
  });
}
