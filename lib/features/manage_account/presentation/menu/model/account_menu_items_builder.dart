import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/model/menu_item_requirement.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/quota_extensions.dart';

/// Builds the list of account menu items based on capabilities and platform
class AccountMenuItemsBuilder {
  final ManageAccountDashBoardController _dashboardController;

  AccountMenuItemsBuilder(this._dashboardController);

  /// Get all menu item requirements with their capability checks
  List<MenuItemRequirement> get _menuItemRequirements => [
        const MenuItemRequirement(
          menuItem: AccountMenuItem.profiles,
          alwaysShow: true,
        ),
        MenuItemRequirement(
          menuItem: AccountMenuItem.emailRules,
          capabilityCheck: () =>
              _dashboardController.isRuleFilterCapabilitySupported,
        ),
        const MenuItemRequirement(
          menuItem: AccountMenuItem.preferences,
          alwaysShow: true, // Always show for local preferences
        ),
        MenuItemRequirement(
          menuItem: AccountMenuItem.forward,
          capabilityCheck: () =>
              _dashboardController.isForwardCapabilitySupported,
        ),
        MenuItemRequirement(
          menuItem: AccountMenuItem.vacation,
          capabilityCheck: () =>
              _dashboardController.isVacationCapabilitySupported,
        ),
        const MenuItemRequirement(
          menuItem: AccountMenuItem.mailboxVisibility,
          alwaysShow: true,
        ),
        MenuItemRequirement(
          menuItem: AccountMenuItem.languageAndRegion,
          capabilityCheck: () =>
              _dashboardController.isLanguageSettingDisplayed,
        ),
        const MenuItemRequirement(
          menuItem: AccountMenuItem.keyboardShortcuts,
          webOnly: true,
        ),
      ];

  /// Build the filtered list of menu items that should be shown
  List<AccountMenuItem> buildMenuItems() {
    return _menuItemRequirements
        .where((requirement) => requirement.shouldShow())
        .map((requirement) => requirement.menuItem)
        .toList();
  }

  /// Check if storage menu item can be added
  bool canAddStorage() {
    final octetsQuota = _dashboardController.octetsQuota.value;
    return octetsQuota != null && octetsQuota.storageAvailable;
  }
}
