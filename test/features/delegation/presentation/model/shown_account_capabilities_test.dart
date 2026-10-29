import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_capabilities.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  group('ShownAccountCapabilities.of', () {
    final session = DelegationFixtures.session();

    for (final (shown, shownAccount, canOpenSettings) in [
      ('my own account', ActiveAccount.personal(session), true),
      ('a delegated account', ActiveAccount.delegated(session, DelegationFixtures.bobAccountId), false),
      ('no account yet', null, true),
    ]) {
      test('${canOpenSettings ? 'opens' : 'does not open'} Settings while $shown is shown', () {
        expect(ShownAccountCapabilities.of(shownAccount).canOpenSettings, canOpenSettings);
      });
    }

    test('gives equal capabilities for my own account and no account yet', () {
      expect(ShownAccountCapabilities.of(ActiveAccount.personal(session)), ShownAccountCapabilities.of(null));
    });
  });
}
