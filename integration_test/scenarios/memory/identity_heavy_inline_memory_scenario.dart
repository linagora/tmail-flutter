import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import '../../memory/heavy_png.dart';
import '../../robots/identity_creator_robot.dart';
import '../../robots/profiles_robot.dart';
import 'memory_leak_scenario.dart';

/// Every cycle deletes the identity it created: a saved identity keeps its
/// signature on purpose, which would read as a leak.
class IdentityHeavyInlineMemoryScenario extends MemoryLeakScenario {
  const IdentityHeavyInlineMemoryScenario(super.$, super.robots);

  @override
  String get caseId => 'identity_heavy_inline';

  @override
  Future<void> prepare() async {
    await robots.mailboxMenuRobot().openSetting();
    await robots.settingsRobot().openSettingsDetail(AccountMenuItem.profiles);
    await expectViewVisible($(#create_new_identity_button));
  }

  @override
  Future<void> runCycle(MemoryCycle cycle) async {
    final name = 'Memory identity ${cycle.name}';
    final profilesRobot = ProfilesRobot($);
    final identityCreatorRobot = IdentityCreatorRobot($);

    await profilesRobot.tapCreateNewIdentityButton();
    await identityCreatorRobot.enterName(name);
    await identityCreatorRobot.addSignatureInline(
      heavyImageBytes,
      'signature.png',
    );
    await identityCreatorRobot.tapSaveIdentityButton();
    await expectViewVisible($(name));

    await profilesRobot.deleteIdentity(name);
  }
}
