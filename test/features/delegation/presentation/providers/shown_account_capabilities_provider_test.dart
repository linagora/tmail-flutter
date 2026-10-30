import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/shown_account_capabilities_provider.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  ActiveAccountNotifier notifierOf() => container.read(activeAccountProvider.notifier);
  bool canOpenSettings() => container.read(shownAccountCapabilitiesProvider).canOpenSettings;

  test('opens Settings before any account is shown', () {
    expect(canOpenSettings(), isTrue);
  });

  test('opens Settings while my own account is shown', () {
    notifierOf().applySession(DelegationFixtures.session());

    expect(canOpenSettings(), isTrue);
  });

  test('does not open Settings while a delegated account is shown', () {
    notifierOf().applySession(DelegationFixtures.session());
    notifierOf().select(DelegationFixtures.bobAccountId);

    expect(canOpenSettings(), isFalse);
  });

  test('notifies its listeners on each switch between my own account and a delegated account', () async {
    final values = <bool>[];
    container.listen(
      shownAccountCapabilitiesProvider,
      (_, capabilities) => values.add(capabilities.canOpenSettings),
      fireImmediately: true,
    );
    notifierOf().applySession(DelegationFixtures.session());

    notifierOf().select(DelegationFixtures.bobAccountId);
    await container.pump();
    notifierOf().selectPersonal();
    await container.pump();

    expect(values, [true, false, true]);
  });

  test('opens Settings again once a session re-read no longer lists the shown delegated account', () {
    notifierOf().applySession(DelegationFixtures.session());
    notifierOf().select(DelegationFixtures.bobAccountId);

    notifierOf().applySession(DelegationFixtures.session(listsBob: false));

    expect(canOpenSettings(), isTrue);
  });

  test('opens Settings again once the signed-in session ends', () {
    notifierOf().applySession(DelegationFixtures.session());
    notifierOf().select(DelegationFixtures.bobAccountId);

    notifierOf().clear();

    expect(canOpenSettings(), isTrue);
  });
}
