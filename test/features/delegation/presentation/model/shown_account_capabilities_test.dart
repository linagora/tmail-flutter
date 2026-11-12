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
          canApplyMyComposerSettings,
          showsViewingOwnerChrome,
          offersServerDefaultIdentities,
          showsMyVacationBanner,
          canRecoverDeletedMessages,
          offersMyPremium,
          namesShownAccountInWebUrl,
          opensInboxForMissingLinkTarget,
          switchesToMineBeforeIntent,
        ) in [
      (
        'my own account',
        ActiveAccount.personal(session),
        true,
        true,
        true,
        true,
        true,
        false,
        false,
        true,
        true,
        true,
        false,
        false,
        false,
      ),
      (
        'a delegated account',
        ActiveAccount.delegated(session, DelegationFixtures.bobAccountId),
        false,
        false,
        false,
        false,
        false,
        true,
        true,
        false,
        false,
        false,
        true,
        true,
        true,
      ),
      (
        'no account yet',
        null,
        true,
        true,
        false,
        false,
        true,
        false,
        false,
        true,
        true,
        true,
        false,
        false,
        false,
      ),
    ]) {
      test(
        '${canOpenSettings ? 'opens' : 'does not open'} Settings, '
        '${canCreateFilter ? 'allows' : 'does not allow'} creating a filter, '
        '${canCreateDefaultFolders ? 'creates' : 'does not create'} default folders, '
        '${canUseNotificationKeychain ? 'writes' : 'does not write'} the notification keychain, '
        '${canApplyMyComposerSettings ? 'applies' : 'does not apply'} my composer settings, '
        '${showsViewingOwnerChrome ? 'shows' : 'does not show'} Viewing owner chrome and '
        '${offersServerDefaultIdentities ? 'offers' : 'does not offer'} server default identities, '
        '${showsMyVacationBanner ? 'shows' : 'does not show'} my vacation banner, '
        '${canRecoverDeletedMessages ? 'allows' : 'does not allow'} recovering deleted messages, '
        '${offersMyPremium ? 'offers' : 'does not offer'} my premium, '
        '${namesShownAccountInWebUrl ? 'names' : 'does not name'} the account in web URLs, '
        '${opensInboxForMissingLinkTarget ? 'opens Inbox' : 'opens the unknown page'} for a missing link target, '
        '${switchesToMineBeforeIntent ? 'switches' : 'does not switch'} to mine before an intent '
        'while $shown is shown',
        () {
          final capabilities = ShownAccountCapabilities.of(shownAccount);

          expect(capabilities.canOpenSettings, canOpenSettings);
          expect(capabilities.canCreateFilter, canCreateFilter);
          expect(capabilities.canCreateDefaultFolders, canCreateDefaultFolders);
          expect(capabilities.canUseNotificationKeychain, canUseNotificationKeychain);
          expect(capabilities.canApplyMyComposerSettings, canApplyMyComposerSettings);
          expect(capabilities.showsViewingOwnerChrome, showsViewingOwnerChrome);
          expect(capabilities.offersServerDefaultIdentities, offersServerDefaultIdentities);
          expect(capabilities.showsMyVacationBanner, showsMyVacationBanner);
          expect(capabilities.canRecoverDeletedMessages, canRecoverDeletedMessages);
          expect(capabilities.offersMyPremium, offersMyPremium);
          expect(capabilities.namesShownAccountInWebUrl, namesShownAccountInWebUrl);
          expect(capabilities.opensInboxForMissingLinkTarget, opensInboxForMissingLinkTarget);
          expect(capabilities.switchesToMineBeforeIntent, switchesToMineBeforeIntent);
        },
      );
    }

    test('opens Settings and allows creating a filter for my own account and no account yet', () {
      final mine = ShownAccountCapabilities.of(ActiveAccount.personal(session));
      final none = ShownAccountCapabilities.of(null);

      expect(mine.canOpenSettings, none.canOpenSettings);
      expect(mine.canCreateFilter, none.canCreateFilter);
    });

    test('equals the capabilities of the same shown account and differs from another', () {
      final delegated = ActiveAccount.delegated(session, DelegationFixtures.bobAccountId);

      expect(ShownAccountCapabilities.of(delegated), ShownAccountCapabilities.of(delegated));
      expect(ShownAccountCapabilities.of(delegated), isNot(ShownAccountCapabilities.of(ActiveAccount.personal(session))));
    });
  });
}
