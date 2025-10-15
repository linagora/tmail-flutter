import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../base/base_test_scenario.dart';
import '../../../robots/identity_creator_robot.dart';
import '../../../robots/mailbox_menu_robot.dart';
import '../../../robots/profiles_robot.dart';
import '../../../robots/setting_robot.dart';
import '../../../robots/thread_robot.dart';

class CreateNewIdentityScenario extends BaseTestScenario {
  final List<String>? identityNames;

  const CreateNewIdentityScenario(super.$, {this.identityNames});

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final settingRobot = SettingRobot($);
    final profilesRobot = ProfilesRobot($);
    final identityCreatorRobot = IdentityCreatorRobot($);
    final appLocalizations = AppLocalizations();

    await threadRobot.openMailbox();
    await _expectUserAvatarVisible();

    await mailboxMenuRobot.openSetting();
    await _expectSettingViewVisible(appLocalizations);
    await $.pumpAndTrySettle();
    await _expectProfilesMenuItemVisible();

    await settingRobot.openProfilesMenuItem();
    await $.pumpAndTrySettle();
    await _expectCreateNewIdentityButtonVisible();

    if (identityNames?.isNotEmpty == true) {
      for (var name in identityNames!) {
        await profilesRobot.tapCreateNewIdentityButton();
        await _expectIdentityCreatorViewVisible();
        await identityCreatorRobot.enterName(name);
        await identityCreatorRobot.tapSaveIdentityButton();
        await $.pumpAndTrySettle(duration: const Duration(seconds: 1));
        await _expectIdentityVisible(name);
      }
    } else {
      await profilesRobot.tapCreateNewIdentityButton();
      await _expectIdentityCreatorViewVisible();
      await identityCreatorRobot.enterName('New Identity');
      await identityCreatorRobot.tapSaveIdentityButton();
      await $.pumpAndTrySettle(duration: const Duration(seconds: 1));
      await _expectIdentityVisible('New Identity');
    }
  }

  Future<void> _expectUserAvatarVisible() => expectViewVisible($(#user_avatar));

  Future<void> _expectSettingViewVisible(AppLocalizations appLocalizations) =>
      expectViewVisible($(find.text(appLocalizations.settings)));

  Future<void> _expectProfilesMenuItemVisible() async {
    await expectViewVisible($(#setting_profiles));
  }

  Future<void> _expectCreateNewIdentityButtonVisible() =>
      expectViewVisible($(#create_new_identity_button));

  Future<void> _expectIdentityCreatorViewVisible() =>
      expectViewVisible($(IdentityCreatorView));

  Future<void> _expectIdentityVisible(String name) async {
    await expectViewVisible($(name));
  }
}
