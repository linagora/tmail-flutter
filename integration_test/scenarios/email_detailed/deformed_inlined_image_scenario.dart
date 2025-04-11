import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/thread_robot.dart';

class DeformedInlinedImageScenario extends BaseTestScenario {
  const DeformedInlinedImageScenario(super.$);

  static const String subject = 'Deformed inlined image';
  static const String content = '''
    <img 
      src="https://example.com/image.jpg"
      alt="inline-image-no-style"/>
    <br>
    <img 
      src="https://example.com/image.jpg"
      style="width: 2000px; height: 200px;" 
      alt="inline-image-oversize-with-style"/>
    <br>
    <img 
      src="https://example.com/image.jpg"
      width="2000" 
      height="200"
      alt="inline-image-oversize-with-width-attribute"/>
    <br>
    <img 
      src="https://example.com/image.jpg"
      style="width: 2000px; height: 200px;" 
      width="2000"
      height="200"
      alt="inline-image-oversize-with-style-and-width-attribute"/>
    <br>
    <img 
      src="https://example.com/image.jpg"
      width="100" 
      height="100"
      alt="inline-image-normal-size-with-width-attribute"/>
    <br>
    <img 
      src="https://example.com/image.jpg"
      style="width: 100px; height: 100px;" 
      width="100"
      height="100"
      alt="inline-image-normal-size-with-style-and-width-attribute"/>
  ''';

  @override
  Future<void> runTestLogic() async {
    PlatformInfo.isIntegrationTesting = true;

    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final provisioningEmail = ProvisioningEmail(
      toEmail: emailUser,
      subject: subject,
      content: content,
    );

    await provisionEmail([provisioningEmail], requestReadReceipt: false);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));
    await _expectDisplayedEmailWithSubject();

    final threadRobot = ThreadRobot($);
    await threadRobot.openEmailWithSubject(subject);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));
    await _expectEmailViewDisplaysNormalizedInlineImages();

    PlatformInfo.isIntegrationTesting = false;
  }

  Future<void> _expectDisplayedEmailWithSubject() async {
    await expectViewVisible(
      $(EmailTileBuilder).which<EmailTileBuilder>(
        (widget) => widget.presentationEmail.subject == subject
      ),
    );
  }

  Future<void> _expectEmailViewDisplaysNormalizedInlineImages() async {
    HtmlContentViewer? htmlContentViewer;
    await $(HtmlContentViewer)
      .which<HtmlContentViewer>((view) {
        htmlContentViewer = view;
        return true;
      })
      .first
      .tap();
    expect(htmlContentViewer, isNotNull);
    log('DeformedInlinedImageScenario::_expectEmailViewDisplaysNormalizedInlineImages:initialWidth = ${htmlContentViewer?.initialWidth}');
    expect(htmlContentViewer?.contentHtml.isNotEmpty, isTrue);

    SingleEmailController? emailController;
    await $(EmailView)
      .which<EmailView>((view) {
        emailController = view.controller;
        return true;
      })
      .first
      .tap();
    expect(emailController, isNotNull);

    final webViewController = emailController
      ?.htmlContentViewKey
      ?.currentState
      ?.webViewController;
    expect(webViewController, isNotNull);

    final result = await webViewController?.evaluateJavascript(
      source: '''
        (function() {
          const images = document.querySelectorAll('img');
          return Array.from(images).map(img => ({
            src: img.getAttribute('src'),
            width: img.getAttribute('width'),
            height: img.getAttribute('height'),
            style: img.getAttribute('style'),
            alt: img.getAttribute('alt'),
            outerHTML: img.outerHTML
          }));
        })();
      '''
    );

    final imageList = List<Map<String, dynamic>>.from(result);

    expect(imageList.length, 6);

    for (var img in imageList) {
      final imgWidth= img['width'];
      final imgHeight = img['height'];
      final imgStyle = img['style'];
      final imgAlt = img['alt'];
      final imgOuterHTML = img['outerHTML'];
      log("DeformedInlinedImageScenario::_expectEmailViewDisplaysNormalizedInlineImages:Image $imgOuterHTML");

      if (imgAlt == 'inline-image-normal-size-with-width-attribute') {
        expect(imgStyle, isNull);
        expect(imgWidth, equals('100'));
        expect(imgHeight, equals('100'));
      } else if (imgAlt == 'inline-image-normal-size-with-style-and-width-attribute') {
        expect(imgStyle.contains('max-width: 100%;'), isFalse);
        expect(imgStyle.contains('width: 100px; height: 100px;'), isTrue);
        expect(imgWidth, equals('100'));
        expect(imgHeight, equals('100'));
      } else {
        expect(imgStyle, equals('max-width: 100%;height: auto;display: inline;'));
        expect(imgWidth, isNull);
        expect(imgHeight, isNull);
      }
    }
  }
}