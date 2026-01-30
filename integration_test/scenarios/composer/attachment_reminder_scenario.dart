import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_mobile_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_identity.dart';
import '../../robots/composer_robot.dart';
import '../../robots/identities_list_menu_robot.dart';
import '../../robots/thread_robot.dart';

class AttachmentReminderScenario extends BaseTestScenario {
  const AttachmentReminderScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final identitiesListMenuRobot = IdentitiesListMenuRobot($);
    final imagePaths = ImagePaths();
    final appLocalizations = AppLocalizations();

    final identity1 = Identity(
      name: 'Identity with attachment keyword',
      email: email,
      htmlSignature: Signature('Signature file'),
      sortOrder: UnsignedInt(0),
    );
    final identity2 = Identity(
      name: 'Identity without attachment keyword',
      email: email,
      htmlSignature: Signature('Signature'),
      sortOrder: UnsignedInt(100),
    );
    await provisionIdentities([
      ProvisioningIdentity(identity: identity1, isDefault: true),
      ProvisioningIdentity(identity: identity2),
    ]);
    await $.pumpAndSettle();

    // Send email with attachment keyword in signature
    await threadRobot.openComposer();
    await $.pumpAndSettle();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();
    await composerRobot.addSubject('Test Reminder');
    await composerRobot.addContent('Test Reminder');
    await composerRobot.tapToRecipientExpandButton();
    await $.pumpAndSettle();
    await _expectIdentityVisible(identity1);
    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: email,
    );
    await composerRobot.sendEmail(imagePaths);
    await _expectSendEmailSuccessToast(appLocalizations);

    // Send email without attachment keyword in signature
    await threadRobot.openComposer();
    await $.pumpAndSettle();
    await composerRobot.grantContactPermission();
    await composerRobot.addSubject('Test Reminder');
    await composerRobot.addContent('file in content');
    await composerRobot.tapToRecipientExpandButton();
    await $.pumpAndSettle();
    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: email,
    );
    await composerRobot.tapFromFieldPopupMenu();
    await identitiesListMenuRobot.selectIdentityByName(identity2.name!);
    await $.pumpAndSettle();
    await _expectIdentityVisible(identity2);

    await composerRobot.sendEmail(imagePaths);
    await _expectAttachmentReminderModalVisible();
  }

  Future<void> _expectComposerViewVisible() =>
      expectViewVisible($(ComposerView));

  Future<void> _expectAttachmentReminderModalVisible() =>
      expectViewVisible($(find.textContaining(
          'in your message but did not add any attachments. Do you still want to send?')));

  Future<void> _expectIdentityVisible(Identity identity) async {
    expect(
      $(FromComposerMobileWidget)
          .which<FromComposerMobileWidget>(
              (widget) => widget.selectedIdentity?.name == identity.name)
          .visible,
      isTrue,
    );
  }

  Future<void> _expectSendEmailSuccessToast(
      AppLocalizations appLocalizations) async {
    await expectViewVisible(
      $(find.text(appLocalizations.message_has_been_sent_successfully)),
    );
  }
}
