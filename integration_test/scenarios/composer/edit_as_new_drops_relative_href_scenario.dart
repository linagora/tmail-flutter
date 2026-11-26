import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';

/// Edit as new loads the sender's HTML into the composer. The editor's link
/// tooltip opens an href in the app window, so a relative href must be dropped
/// there, while an absolute link stays usable.
class EditAsNewDropsRelativeHrefScenario extends BaseTestScenario {
  const EditAsNewDropsRelativeHrefScenario(super.$, super.robots);

  static const _subject = 'edit as new drops relative href';
  static const _relativeLinkText = 'relative link';
  static const _absoluteLinkText = 'absolute link';
  static const _absoluteHref = 'https://example.com/';

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    if (email.isEmpty) throw StateError('BASIC_AUTH_EMAIL must not be empty');

    await robots.commonRobot().provisionEmail([
      ProvisioningEmail(
        toEmail: email,
        subject: _subject,
        content:
            '<p><a href="/mailto?uri=mailto%3Aattacker%40evil.test">$_relativeLinkText</a></p>'
            '<p><a href="$_absoluteHref">$_absoluteLinkText</a></p>',
      ),
    ], requestReadReceipt: false);

    await robots.threadRobot().openEmailWithSubject(_subject);
    await robots.emailRobot().editAsNewEmail();

    final composerRobot = robots.composerRobot();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    final editorLinks = composerRobot.editorLinks;
    if (editorLinks == null) {
      throw StateError('Editor link checks are not wired on this platform');
    }
    await editorLinks.expectLinkHref(_absoluteLinkText, _absoluteHref);
    await editorLinks.expectLinkHref(_relativeLinkText, null);

    await composerRobot.tapCloseComposer();
    await composerRobot.expectComposerClosedDiscardingChanges();
  }
}
