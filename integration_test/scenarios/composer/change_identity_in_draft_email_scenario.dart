import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_mobile_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_identity.dart';
import '../../robots/composer_robot.dart';
import '../../robots/identities_list_menu_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class ChangeIdentityInDraftEmailScenario extends BaseTestScenario {
  const ChangeIdentityInDraftEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Change identity in draft email';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final identitiesListMenuRobot = IdentitiesListMenuRobot($);
    final imagePaths = ImagePaths();
    final appLocalizations = AppLocalizations();

    final identity1 = Identity(
      name: 'Identity 1',
      email: email,
      htmlSignature: Signature('Signature 1'),
      sortOrder: UnsignedInt(0),
    );
    final identity2 = Identity(
      name: 'Identity 2',
      email: email,
      htmlSignature: Signature('Signature 2'),
      sortOrder: UnsignedInt(100),
    );
    await provisionIdentities([
      ProvisioningIdentity(identity: identity1, isDefault: true),
      ProvisioningIdentity(identity: identity2),
    ]);
    await $.pumpAndSettle();

    await threadRobot.openComposer();
    await $.pumpAndSettle();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addSubject(subject);
    await composerRobot.addContent(subject);

    await composerRobot.tapRecipientExpandButton();
    await $.pumpAndSettle();
    await _expectIdentityVisible(identity1);

    await composerRobot.tapFromFieldPopupMenu();
    await identitiesListMenuRobot.selectIdentityByName(identity2.name!);
    await $.pumpAndSettle();
    await _expectIdentityVisible(identity2);

    await composerRobot.tapMoreOptionOnAppBar();
    await _expectSaveAsDraftOptionPopupMenuVisible();

    await composerRobot.tapSaveAsDraftPopupItemOnMenu();
    await _expectSaveAsDraftEmailSuccessToast(appLocalizations);

    await composerRobot.tapCloseComposer(imagePaths);

    await threadRobot.openMailbox();
    await mailboxMenuRobot
        .openFolderByName(appLocalizations.draftsMailboxDisplayName);

    await threadRobot.openEmailWithSubject(subject);
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.tapRecipientExpandButton();
    await $.pumpAndSettle();
    await _expectIdentityVisible(identity2);
  }

  Future<void> _expectComposerViewVisible() =>
      expectViewVisible($(ComposerView));

  Future<void> _expectSaveAsDraftOptionPopupMenuVisible() =>
      expectViewVisible($(#save_as_draft_popup_item));

  Future<void> _expectSaveAsDraftEmailSuccessToast(
    AppLocalizations appLocalizations,
  ) =>
      expectViewVisible($(appLocalizations.drafts_saved));

  Future<void> _expectIdentityVisible(Identity identity) async {
    expect(
      $(FromComposerMobileWidget).which<FromComposerMobileWidget>(
        (widget) => widget.selectedIdentity?.name == identity.name
      ).visible,
      isTrue,
    );
  }
}
