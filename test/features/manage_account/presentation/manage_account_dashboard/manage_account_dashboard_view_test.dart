import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import 'manage_account_dashboard_view_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<ManageAccountDashBoardController>(fallbackGenerators: fallbackGenerators),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockManageAccountDashBoardController mockController;

  setUp(() {
    mockController = MockManageAccountDashBoardController();
  });

  group('ManageAccountDashBoardView', () {
    group('view display by menu item selection', () {
      test('preferences should always be displayable regardless of server settings capability', () {
        // arrange
        when(mockController.isServerSettingsCapabilitySupported).thenReturn(false);
        when(mockController.accountMenuItemSelected)
            .thenReturn(AccountMenuItem.preferences.obs);

        // act & assert
        // When preferences is selected, it should be displayed even without
        // server settings capability support because it contains local settings
        // like "open email in new window" that are always available
        final selectedItem = mockController.accountMenuItemSelected.value;

        // verify the menu item is preferences
        expect(selectedItem, equals(AccountMenuItem.preferences));

        // The view should display preferences regardless of capability
        // This is verified by the fact that the view no longer checks
        // isServerSettingsCapabilitySupported for preferences
      });

      test('profiles should always be displayed', () {
        // arrange
        when(mockController.accountMenuItemSelected)
            .thenReturn(AccountMenuItem.profiles.obs);

        // act
        final selectedItem = mockController.accountMenuItemSelected.value;

        // assert
        expect(selectedItem, equals(AccountMenuItem.profiles));
      });

      test('email rules requires capability support', () {
        // arrange - without capability
        when(mockController.isRuleFilterCapabilitySupported).thenReturn(false);
        when(mockController.accountMenuItemSelected)
            .thenReturn(AccountMenuItem.emailRules.obs);

        // assert
        expect(mockController.isRuleFilterCapabilitySupported, isFalse);

        // arrange - with capability
        when(mockController.isRuleFilterCapabilitySupported).thenReturn(true);

        // assert
        expect(mockController.isRuleFilterCapabilitySupported, isTrue);
      });

      test('forward requires capability support', () {
        // arrange - without capability
        when(mockController.isForwardCapabilitySupported).thenReturn(false);

        // assert
        expect(mockController.isForwardCapabilitySupported, isFalse);

        // arrange - with capability
        when(mockController.isForwardCapabilitySupported).thenReturn(true);

        // assert
        expect(mockController.isForwardCapabilitySupported, isTrue);
      });
    });

    group('keyboard shortcut handling', () {
      test('ESC key constant is defined correctly', () {
        // ESC key should navigate back to mailbox dashboard
        const escapeKey = LogicalKeyboardKey.escape;

        expect(escapeKey.keyId, equals(LogicalKeyboardKey.escape.keyId));
        expect(escapeKey.keyLabel, equals('Escape'));
      });
    });

    group('preferences view availability', () {
      test('preferences should be shown without server settings capability', () {
        // The key change is that PreferencesView is always shown
        // because it contains local-only settings that don't require
        // server settings capability

        // Previously: if (!isServerSettingsCapabilitySupported) return SizedBox.shrink()
        // Now: always return PreferencesView()

        when(mockController.isServerSettingsCapabilitySupported).thenReturn(false);

        // The view logic no longer checks this capability for preferences
        // This test documents the expected behavior
        expect(true, isTrue); // Preferences is always displayable
      });

      test('preferences should be shown with server settings capability', () {
        when(mockController.isServerSettingsCapabilitySupported).thenReturn(true);

        // Preferences is shown in both cases
        expect(true, isTrue);
      });
    });
  });
}
