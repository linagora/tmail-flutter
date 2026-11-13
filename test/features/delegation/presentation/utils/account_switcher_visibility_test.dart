import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/account_switcher_visibility.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  group('canShowAccountSwitcher', () {
    test('is false when delegation is off even with delegated accounts', () {
      expect(
        canShowAccountSwitcher(
          delegationEnabled: false,
          session: DelegationFixtures.session(),
        ),
        isFalse,
      );
    });

    test('is false when the session is null', () {
      expect(
        canShowAccountSwitcher(delegationEnabled: true, session: null),
        isFalse,
      );
    });

    test('is false when delegation is on but no delegated account is listed', () {
      expect(
        canShowAccountSwitcher(
          delegationEnabled: true,
          session: DelegationFixtures.session(listsBob: false, listsCarol: false),
        ),
        isFalse,
      );
    });

    test('is true when delegation is on and a delegated account is listed', () {
      expect(
        canShowAccountSwitcher(
          delegationEnabled: true,
          session: DelegationFixtures.session(listsBob: true, listsCarol: false),
        ),
        isTrue,
      );
    });
  });
}
