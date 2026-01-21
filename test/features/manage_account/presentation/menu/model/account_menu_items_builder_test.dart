import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/model/account_menu_items_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import 'account_menu_items_builder_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<ManageAccountDashBoardController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  late MockManageAccountDashBoardController mockDashboardController;
  late AccountMenuItemsBuilder builder;

  setUp(() {
    mockDashboardController = MockManageAccountDashBoardController();
    builder = AccountMenuItemsBuilder(mockDashboardController);
  });

  group('AccountMenuItemsBuilder', () {
    group('buildMenuItems', () {
      test('should always include profiles menu item', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, contains(AccountMenuItem.profiles));
      });

      test('should always include preferences menu item', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, contains(AccountMenuItem.preferences));
      });

      test('should always include mailbox visibility menu item', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, contains(AccountMenuItem.mailboxVisibility));
      });

      test('should include email rules when capability is supported', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, contains(AccountMenuItem.emailRules));
      });

      test('should exclude email rules when capability is not supported', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, isNot(contains(AccountMenuItem.emailRules)));
      });

      test('should include forward when capability is supported', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, contains(AccountMenuItem.forward));
      });

      test('should exclude forward when capability is not supported', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, isNot(contains(AccountMenuItem.forward)));
      });

      test('should include vacation when capability is supported', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, contains(AccountMenuItem.vacation));
      });

      test('should exclude vacation when capability is not supported', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, isNot(contains(AccountMenuItem.vacation)));
      });

      test('should include language and region when setting is displayed', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(true);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, contains(AccountMenuItem.languageAndRegion));
      });

      test('should exclude language and region when setting is not displayed', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(false);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(false);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, isNot(contains(AccountMenuItem.languageAndRegion)));
      });

      test('should include all items when all capabilities are supported', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(true);

        // act
        final menuItems = builder.buildMenuItems();

        // assert
        expect(menuItems, contains(AccountMenuItem.profiles));
        expect(menuItems, contains(AccountMenuItem.emailRules));
        expect(menuItems, contains(AccountMenuItem.preferences));
        expect(menuItems, contains(AccountMenuItem.forward));
        expect(menuItems, contains(AccountMenuItem.vacation));
        expect(menuItems, contains(AccountMenuItem.mailboxVisibility));
        expect(menuItems, contains(AccountMenuItem.languageAndRegion));
      });

      test('should return items in correct order', () {
        // arrange
        when(mockDashboardController.isRuleFilterCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isForwardCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isVacationCapabilitySupported)
            .thenReturn(true);
        when(mockDashboardController.isLanguageSettingDisplayed)
            .thenReturn(true);

        // act
        final menuItems = builder.buildMenuItems();

        // assert - verify expected order
        expect(menuItems.indexOf(AccountMenuItem.profiles), 0);
        expect(
          menuItems.indexOf(AccountMenuItem.emailRules),
          lessThan(menuItems.indexOf(AccountMenuItem.preferences)),
        );
        expect(
          menuItems.indexOf(AccountMenuItem.preferences),
          lessThan(menuItems.indexOf(AccountMenuItem.forward)),
        );
        expect(
          menuItems.indexOf(AccountMenuItem.forward),
          lessThan(menuItems.indexOf(AccountMenuItem.vacation)),
        );
      });
    });

  });
}
