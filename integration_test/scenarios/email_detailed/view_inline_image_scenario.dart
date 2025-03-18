import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import '../../base/base_test_scenario.dart';
import '../../resources/image_resources.dart';
import '../../robots/composer_robot.dart';
import '../../robots/thread_robot.dart';

class ViewInlineImageScenario extends BaseTestScenario {

  const ViewInlineImageScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const emailSubject = 'View inline image in email view';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final imagePaths = ImagePaths();

    await _createEmailWithInlineImage(
      threadRobot: threadRobot,
      composerRobot: composerRobot,
      imagePaths: imagePaths,
      emailUser: emailUser,
      emailSubject: emailSubject,
    );

    await threadRobot.openEmailWithSubject(emailSubject);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));
    await _expectEmailViewWithCidImageVisible();
  }

  Future<void> _createEmailWithInlineImage({
    required ThreadRobot threadRobot,
    required ComposerRobot composerRobot,
    required ImagePaths imagePaths,
    required String emailUser,
    required String emailSubject,
  }) async {
    await threadRobot.openComposer();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: emailUser,
    );
    await composerRobot.addSubject(emailSubject);

    final imageFile = await generateImageFromBase64(
      fileName: 'inline-image.png',
      base64Data: ImageResources.base64,
    );
    await composerRobot.addInlineImageFromFile(imageFile);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    await _expectInlineImageVisible();

    await composerRobot.sendEmail(imagePaths);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    await _expectEmailWithInlineImageVisible(emailSubject);
  }

  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectInlineImageVisible() async {
    final currentHtmlContent = await getBinding<ComposerController>()?.getContentInEditor() ?? '';
    expect(
      currentHtmlContent.contains('data:image/') &&
          currentHtmlContent.contains(';base64') &&
          currentHtmlContent.contains('cid:'),
      isTrue,
    );
  }

  Future<void> _expectEmailWithInlineImageVisible(String emailSubject) async {
    await expectViewVisible(
      $(EmailTileBuilder).which<EmailTileBuilder>(
          (widget) => widget.presentationEmail.subject == emailSubject),
    );
  }

  Future<void> _expectEmailViewWithCidImageVisible() async {
    HtmlContentViewer? htmlContentViewer;

    await $(HtmlContentViewer)
      .which<HtmlContentViewer>((view) {
        htmlContentViewer = view;
        return true;
      })
      .first
      .tap();

    final contentHtml = htmlContentViewer!.contentHtml;
    final cidCount = RegExp(r'cid').allMatches(contentHtml).length;
    expect(cidCount, 1);
  }
}