import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identities_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/identities_view.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/identities/widgets/identity_list_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import '../utils/test_timeouts.dart';
import '../utils/wait_for_condition.dart';

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

  /// Opens the real delete confirmation for [name], confirms it and waits
  /// until the identity is gone from the list.
  Future<void> deleteIdentity(String name) async {
    final controller = Get.find<IdentitiesController>();
    final identity = controller.listAllIdentities.firstWhere(
      (identity) => identity.name == name,
      orElse: () => throw StateError('No identity named "$name" to delete'),
    );
    final context = $.tester.element(find.byType(IdentitiesView));
    controller.openConfirmationDialogDeleteIdentityAction(context, identity);
    await $(#confirm_dialog_delete_identity).$(AppLocalizations().delete).tap();
    await waitForCondition(
      () => !controller.listAllIdentities.any((item) => item.name == name),
      timeout: TestTimeouts.long,
      reason: 'The identity "$name" should be removed from the list',
    );
  }
}
