
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class MarkAsUnreadEmailScenario extends BaseTestScenario {

  const MarkAsUnreadEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const subject = 'Mark as unread email';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);

    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndSettle();

    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle();
    _expectEmailDetailedMoreButtonVisible();

    await emailRobot.tapEmailDetailedMoreButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    await emailRobot.tapMarkAsUnreadOptionInContextMenu();
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    _expectEmailViewInvisible();
    await _expectDisplayedEmailHasUnreadIcon(subject);
  }

  void _expectEmailDetailedMoreButtonVisible() {
    expect($(#email_detailed_more_button), findsOneWidget);
  }

  void _expectEmailViewInvisible() {
    expect($(EmailView).visible, isFalse);
  }

  Future<void> _expectDisplayedEmailHasUnreadIcon(String subject) async {
    await expectViewVisible(
      $(EmailTileBuilder)
          .which<EmailTileBuilder>(
              (widget) => widget.presentationEmail.subject == subject
              && !widget.presentationEmail.hasRead
      ),
    );
    await expectViewVisible($(#unread_status_icon));
  }
}