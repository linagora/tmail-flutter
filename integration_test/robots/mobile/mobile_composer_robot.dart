import 'package:core/presentation/resources/image_paths.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

import '../abstract/abstract_composer_robot.dart';
import '../composer_robot.dart';

class MobileComposerRobot extends ComposerRobot implements AbstractComposerRobot {
  MobileComposerRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> expectComposerViewVisible() async {
    await $.waitUntilVisible($(ComposerView));
  }

  @override
  Future<void> addRecipient(PrefixEmailAddress prefix, String email) =>
      addRecipientIntoField(prefixEmailAddress: prefix, email: email);

  @override
  Future<void> send() => sendEmail(ImagePaths());
}
