import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/utils/delegation_settings_entry.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';


void main() {
  group('shownSettingsMenuItemOrNone', () {
    test('should open Delegation when the entry is shown', () {
      expect(
        shownSettingsMenuItemOrNone(AccountMenuItem.delegation, isDelegationEntryShown: true),
        AccountMenuItem.delegation,
      );
    });

    test('should fall back to none for Delegation when the entry is hidden', () {
      expect(
        shownSettingsMenuItemOrNone(AccountMenuItem.delegation, isDelegationEntryShown: false),
        AccountMenuItem.none,
      );
    });

    test('should not change any other page when the entry is hidden', () {
      expect(
        shownSettingsMenuItemOrNone(AccountMenuItem.storage, isDelegationEntryShown: false),
        AccountMenuItem.storage,
      );
    });
  });

  group('settingsMenuWithDelegationEntry', () {
    const baseMenu = [AccountMenuItem.profiles, AccountMenuItem.storage];

    test('should add Delegation last when the entry is shown', () {
      expect(
        settingsMenuWithDelegationEntry(baseMenu, isDelegationEntryShown: true),
        [AccountMenuItem.profiles, AccountMenuItem.storage, AccountMenuItem.delegation],
      );
    });

    test('should move Delegation back below an entry added after it', () {
      expect(
        settingsMenuWithDelegationEntry(
          [AccountMenuItem.profiles, AccountMenuItem.delegation, AccountMenuItem.storage],
          isDelegationEntryShown: true,
        ),
        [AccountMenuItem.profiles, AccountMenuItem.storage, AccountMenuItem.delegation],
      );
    });

    test('should remove Delegation when the entry is hidden', () {
      expect(
        settingsMenuWithDelegationEntry(
          [...baseMenu, AccountMenuItem.delegation],
          isDelegationEntryShown: false,
        ),
        baseMenu,
      );
    });

    test('should not add Delegation twice when the menu is synced again', () {
      expect(
        settingsMenuWithDelegationEntry(
          [...baseMenu, AccountMenuItem.delegation],
          isDelegationEntryShown: true,
        ),
        [...baseMenu, AccountMenuItem.delegation],
      );
    });
  });
}
