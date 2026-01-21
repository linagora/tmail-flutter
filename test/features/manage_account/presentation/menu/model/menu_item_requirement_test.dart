import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/model/menu_item_requirement.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

void main() {
  group('MenuItemRequirement', () {
    group('shouldShow', () {
      test('should return true when alwaysShow is true', () {
        const requirement = MenuItemRequirement(
          menuItem: AccountMenuItem.profiles,
          alwaysShow: true,
        );

        expect(requirement.shouldShow(), isTrue);
      });

      test('should return true when alwaysShow is true regardless of capabilityCheck', () {
        final requirement = MenuItemRequirement(
          menuItem: AccountMenuItem.profiles,
          alwaysShow: true,
          capabilityCheck: () => false,
        );

        expect(requirement.shouldShow(), isTrue);
      });

      test('should return true when capabilityCheck returns true', () {
        final requirement = MenuItemRequirement(
          menuItem: AccountMenuItem.emailRules,
          capabilityCheck: () => true,
        );

        expect(requirement.shouldShow(), isTrue);
      });

      test('should return false when capabilityCheck returns false', () {
        final requirement = MenuItemRequirement(
          menuItem: AccountMenuItem.emailRules,
          capabilityCheck: () => false,
        );

        expect(requirement.shouldShow(), isFalse);
      });

      test('should return true when no conditions are specified', () {
        const requirement = MenuItemRequirement(
          menuItem: AccountMenuItem.mailboxVisibility,
        );

        expect(requirement.shouldShow(), isTrue);
      });

      // Note: webOnly tests would require mocking PlatformInfo.isWeb
      // which is a static property. In a real test environment,
      // you might want to use dependency injection for platform checks.
    });
  });
}
