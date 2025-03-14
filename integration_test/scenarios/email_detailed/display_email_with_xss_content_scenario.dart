
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/thread_robot.dart';

class DisplayEmailWithXssContentScenario extends BaseTestScenario {

  const DisplayEmailWithXssContentScenario(super.$);

  static const String subject = 'Email with xss content';
  static const String xssContent = '<script>alert("XSSRobot")</script>';

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final provisioningEmail = ProvisioningEmail(
      toEmail: emailUser,
      subject: subject,
      content: xssContent,
    );

    await provisionEmail([provisioningEmail], requestReadReceipt: false);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    await _expectDisplayedEmailWithSubject();

    final threadRobot = ThreadRobot($);
    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    await _expectEmailViewWithoutDisplayAlertDialog();
  }

  Future<void> _expectDisplayedEmailWithSubject() async {
    await expectViewVisible(
      $(EmailTileBuilder)
        .which<EmailTileBuilder>(
          (widget) => widget.presentationEmail.subject == subject
        ),
    );
  }

  Future<void> _expectEmailViewWithoutDisplayAlertDialog() async {
    expect(
      find.text('XSSRobot'),
      findsNothing,
    );

    expect(
      $(HtmlContentViewer).which<HtmlContentViewer>((view) {
        return view.contentHtml.contains('XSSRobot');
      }),
      findsNothing,
    );

    expect(
      find.text('says'),
      findsNothing,
    );

    expect(
      find.text('OK'),
      findsNothing,
    );
  }
}