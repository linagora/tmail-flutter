import '../base/base_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/thread_robot.dart';
import 'login_with_oidc.dart';

class SendEmail extends BaseScenario {
  const SendEmail(
    super.$, 
    {
      required this.loginWithOidcScenario,
      required this.additionalRecipient,
      required this.subject,
      required this.content
    }
  );

  final LoginWithOidc loginWithOidcScenario;
  final String additionalRecipient;
  final String subject;
  final String content;

  @override
  Future<void> execute() async {
    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);

    await loginWithOidcScenario.execute();

    await threadRobot.openComposer();
    await threadRobot.expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addReceipient(loginWithOidcScenario.email);
    await composerRobot.addReceipient(additionalRecipient);
    await composerRobot.addSubject(subject);
    await composerRobot.addContent(content);
    await composerRobot.sendEmail();
    await composerRobot.expectSendEmailSuccessToast();
  }
}