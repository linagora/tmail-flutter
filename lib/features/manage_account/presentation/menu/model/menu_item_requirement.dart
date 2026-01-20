import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

/// Defines the requirements for showing a menu item
class MenuItemRequirement {
  final AccountMenuItem menuItem;
  final bool Function()? capabilityCheck;
  final bool webOnly;
  final bool alwaysShow;

  const MenuItemRequirement({
    required this.menuItem,
    this.capabilityCheck,
    this.webOnly = false,
    this.alwaysShow = false,
  });

  /// Check if this menu item should be shown based on current conditions
  bool shouldShow() {
    // Check platform requirement
    if (webOnly && !PlatformInfo.isWeb) {
      return false;
    }

    // Always show items bypass capability check
    if (alwaysShow) {
      return true;
    }

    // Check capability if required
    if (capabilityCheck != null) {
      return capabilityCheck!();
    }

    // Default to showing the item
    return true;
  }
}
