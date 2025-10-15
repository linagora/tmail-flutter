import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/identity_list_tile_builder.dart';

import '../base/core_robot.dart';

class ProfilesRobot extends CoreRobot {
  ProfilesRobot(super.$);

  Future<void> selectIdentityAsDefault(
    String identityName,
    ImagePaths imagePaths,
  ) async {
    await $.scrollUntilVisible(finder: $(identityName));

    await $(IdentityListTileBuilder)
        .which<IdentityListTileBuilder>(
          (widget) {
            return widget.identity.name == identityName;
          },
        )
        .$(InkWell)
        .tap();
  }

  Future<void> tapCreateNewIdentityButton() async {
    await $(#create_new_identity_button).tap();
  }
}
