import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/domain/model/active_account.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/shown_account_capabilities.dart';

import '../../../../fixtures/delegation_fixtures.dart';

void main() {
  group('ShownAccountCapabilities.of', () {
    final session = DelegationFixtures.session();

    for (final (
          shown,
          shownAccount,
          canOpenSettings,
          canCreateFilter,
          canCreateDefaultFolders,
          canUseNotificationKeychain,
        ) in [
      (
        'my own account',
        ActiveAccount.personal(session),
        true,
        true,
        true,
        true,
      ),
      (
        'a delegated account',
        ActiveAccount.delegated(session, DelegationFixtures.bobAccountId),
        false,
        false,
        false,
        false,
      ),
      (
        'no account yet',
        null,
        true,
        true,
        false,
        false,
      ),
    ]) {
      test(
        '${canOpenSettings ? 'opens' : 'does not open'} Settings, '
        '${canCreateFilter ? 'allows' : 'does not allow'} creating a filter, '
        '${canCreateDefaultFolders ? 'creates' : 'does not create'} default folders and '
        '${canUseNotificationKeychain ? 'writes' : 'does not write'} the notification keychain '
        'while $shown is shown',
        () {
          final capabilities = ShownAccountCapabilities.of(shownAccount);

          expect(capabilities.canOpenSettings, canOpenSettings);
          expect(capabilities.canCreateFilter, canCreateFilter);
          expect(capabilities.canCreateDefaultFolders, canCreateDefaultFolders);
          expect(capabilities.canUseNotificationKeychain, canUseNotificationKeychain);
        },
      );
    }

    test('opens Settings and allows creating a filter for my own account and no account yet', () {
      final mine = ShownAccountCapabilities.of(ActiveAccount.personal(session));
      final none = ShownAccountCapabilities.of(null);

      expect(mine.canOpenSettings, none.canOpenSettings);
      expect(mine.canCreateFilter, none.canCreateFilter);
    });
  });
}
