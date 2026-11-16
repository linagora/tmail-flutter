import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

/// A `type=delegation` link opens the default page while the entry is hidden (ADR-0114).
AccountMenuItem shownSettingsMenuItemOrNone(
  AccountMenuItem requestedItem, {
  required bool isDelegationEntryShown,
}) =>
    requestedItem == AccountMenuItem.delegation && !isDelegationEntryShown
        ? AccountMenuItem.none
        : requestedItem;

/// Keeps Delegation last, below Storage, and only while delegation is on.
List<AccountMenuItem> settingsMenuWithDelegationEntry(
  List<AccountMenuItem> items, {
  required bool isDelegationEntryShown,
}) => [
      ...items.where((item) => item != AccountMenuItem.delegation),
      if (isDelegationEntryShown) AccountMenuItem.delegation,
    ];
