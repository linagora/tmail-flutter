import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../base/base_test_scenario.dart';
import '../models/provisioning_email.dart';

class WebSocketUpdateUiScenario extends BaseTestScenario {
  const WebSocketUpdateUiScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'web socket subject';
    const content = 'web socket content';

    await provisionEmail(
      [ProvisioningEmail(
        toEmail: email,
        subject: subject,
        content: content,
      )],
      refreshEmailView: false,
    );
    await $.pumpAndSettle();
    await _expectEmailVisible(subject);
    await _expectEmailUnreadWithSubject(subject);
    await _expectEmailUnstarredWithSubject(subject);

    await simulateUpdateFlagsOfEmailsWithSubjectsFromOutsideCurrentClient(
      subjects: [subject],
      isRead: true,
    );
    await $.pumpAndSettle();
    await _expectEmailReadWithSubject(subject);

    await simulateUpdateFlagsOfEmailsWithSubjectsFromOutsideCurrentClient(
      subjects: [subject],
      isStar: true,
    );
    await $.pumpAndSettle();
    await _expectEmailStarredWithSubject(subject);
  }

  Future<void> _expectEmailVisible(String subject) async {
    await expectViewVisible($(subject));
  }

  Future<void> _expectEmailUnreadWithSubject(String subject) => expectViewVisible(
    $(EmailTileBuilder)
      .which<EmailTileBuilder>(
        (widget) => widget.presentationEmail.subject == subject 
          && !widget.presentationEmail.hasRead
      ),
  );

  Future<void> _expectEmailReadWithSubject(String subject) => expectViewVisible(
    $(EmailTileBuilder)
      .which<EmailTileBuilder>(
        (widget) => widget.presentationEmail.subject == subject 
          && widget.presentationEmail.hasRead
      ),
  );

  Future<void> _expectEmailUnstarredWithSubject(String subject) => expectViewVisible(
    $(EmailTileBuilder)
      .which<EmailTileBuilder>(
        (widget) => widget.presentationEmail.subject == subject 
          && !widget.presentationEmail.hasStarred
      ),
  );

  Future<void> _expectEmailStarredWithSubject(String subject) => expectViewVisible(
    $(EmailTileBuilder)
      .which<EmailTileBuilder>(
        (widget) => widget.presentationEmail.subject == subject 
          && widget.presentationEmail.hasStarred
      ),
  );
}