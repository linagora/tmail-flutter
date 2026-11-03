import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/profile_setting/profile_setting_action_type.dart';

void main() {
  group('ProfileSettingActionType.shown', () {
    test('offers Manage account and Sign out when Settings can open', () {
      expect(
        ProfileSettingActionType.shown(canOpenSettings: true),
        [ProfileSettingActionType.manageAccount, ProfileSettingActionType.signOut],
      );
    });

    test('offers only Sign out when Settings cannot open', () {
      expect(
        ProfileSettingActionType.shown(canOpenSettings: false),
        [ProfileSettingActionType.signOut],
      );
    });
  });
}
