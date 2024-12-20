import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../base/base_scenario.dart';
import '../models/provisioning_email.dart';
import '../utils/scenario_utils_mixin.dart';
import 'login_with_basic_auth_scenario.dart';

class WebSocketUpdateUiScenario extends BaseScenario with ScenarioUtilsMixin {
  const WebSocketUpdateUiScenario(super.$, {
    required this.loginWithBasicAuthScenario,
    required this.subject,
    required this.content,
  });

  final LoginWithBasicAuthScenario loginWithBasicAuthScenario;
  final String subject;
  final String content;

  @override
  Future<void> execute() async {
    await loginWithBasicAuthScenario.execute();

    await provisionEmail(
      [ProvisioningEmail(
        toEmail: loginWithBasicAuthScenario.email,
        subject: subject,
        content: content,
      )],
      refreshEmailView: false,
    );
    await $.pumpAndSettle();
    await _expectEmailVisible(loginWithBasicAuthScenario.email);
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

  Future<void> _expectEmailVisible(String email) => expectViewVisible($(email));

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