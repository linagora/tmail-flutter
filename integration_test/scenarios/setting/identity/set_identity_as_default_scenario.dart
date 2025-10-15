import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/identity_list_tile_builder.dart';

import '../../../base/base_test_scenario.dart';
import '../../../robots/profiles_robot.dart';
import 'create_new_identity_scenario.dart';

class SetIdentityAsDefaultScenario extends BaseTestScenario {
  const SetIdentityAsDefaultScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final profilesRobot = ProfilesRobot($);
    final imagePaths = ImagePaths();
    final createNewIdentityScenario = CreateNewIdentityScenario(
      $,
      identityNames: ['Default Identity 1', 'Default Identity 2'],
    );
    await createNewIdentityScenario.runTestLogic();
    await $.pumpAndTrySettle();

    await profilesRobot.selectIdentityAsDefault(
      'Default Identity 1',
      imagePaths,
    );
    await $.pumpAndTrySettle();
    _expectIdentityAsDefaultVisible('Default Identity 1', imagePaths);

    await profilesRobot.selectIdentityAsDefault(
      'Default Identity 2',
      imagePaths,
    );
    await $.pumpAndTrySettle();
    _expectIdentityAsDefaultVisible('Default Identity 2', imagePaths);
  }

  void _expectIdentityAsDefaultVisible(String name, ImagePaths imagePaths) {
    expect(
      $(IdentityListTileBuilder)
          .which<IdentityListTileBuilder>(
            (widget) {
              return widget.identity.name == name;
            },
          )
          .$(TMailButtonWidget)
          .which<TMailButtonWidget>(
              (widget) => widget.icon == imagePaths.icRadioSelected)
          .exists,
      true,
    );
  }
}
