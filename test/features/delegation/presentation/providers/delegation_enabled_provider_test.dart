import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegation_enabled_provider.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    // Keeps the provider alive, so each read checks that it rebuilt on its own.
    container.listen(delegationEnabledProvider, (_, __) {});
  });
  tearDown(() => container.dispose());

  bool isEnabled() => container.read(delegationEnabledProvider);
  void applySession() => container
      .read(activeAccountProvider.notifier)
      .applySession(DelegationFixtures.session());
  void applySessionWithoutDelegationCapability() => container
      .read(activeAccountProvider.notifier)
      .applySession(DelegationFixtures.sessionWithoutDelegationCapability());

  test('is on when the server has the delegation capability and the Delegation preference is on', () {
    applySession();
    DelegationFixtures.turnDelegationOn(container);

    expect(isEnabled(), isTrue);
  });

  test('is off when the Delegation preference is off, its default', () {
    applySession();

    expect(isEnabled(), isFalse);
  });

  test('is off when the server lacks the delegation capability, even with the preference on', () {
    applySessionWithoutDelegationCapability();
    DelegationFixtures.turnDelegationOn(container);

    expect(isEnabled(), isFalse);
  });

  test('is off before a session is applied, even with the preference on', () {
    DelegationFixtures.turnDelegationOn(container);

    expect(isEnabled(), isFalse);
  });

  test('follows the preference when it is turned on, then off', () {
    applySession();

    DelegationFixtures.turnDelegationOn(container);
    expect(isEnabled(), isTrue);

    container.invalidate(localSettingsProvider);
    expect(isEnabled(), isFalse);
  });

  test('follows a new session that drops the delegation capability', () {
    applySession();
    DelegationFixtures.turnDelegationOn(container);
    expect(isEnabled(), isTrue);

    applySessionWithoutDelegationCapability();

    expect(isEnabled(), isFalse);
  });
}
