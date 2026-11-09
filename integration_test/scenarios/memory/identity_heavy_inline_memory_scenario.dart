import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';

import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_view.dart';

import '../../memory/heavy_png.dart';
import '../../robots/identity_creator_robot.dart';
import '../../robots/profiles_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import 'memory_leak_scenario.dart';

/// Every cycle deletes the identity it created: a saved identity keeps its
/// signature on purpose, which would read as a leak.
class IdentityHeavyInlineMemoryScenario extends MemoryLeakScenario {
  const IdentityHeavyInlineMemoryScenario(super.$, super.robots);

  @override
  String get caseId => 'identity_heavy_inline';

  @override
  Future<void> openStartScreen() async {
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
    // The name also sits in the creator's text field, so wait for the creator to close.
    await waitForCondition(
      () => !$(IdentityCreatorView).exists,
      timeout: TestTimeouts.long,
      reason: 'The identity creator should close after saving',
    );
    await expectViewVisible($(name));

    await profilesRobot.deleteIdentity(name);
  }
}
