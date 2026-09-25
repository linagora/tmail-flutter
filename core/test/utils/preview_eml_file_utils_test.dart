import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';

void main() {
  String generatePreviewEml(String emailContent) {
    return PreviewEmlFileUtils().generatePreviewEml(
      appName: 'Twake Mail',
      ownEmailAddress: 'bob@example.com',
      subjectPrefix: 'Subject',
      subject: 'Hello',
      emailContent: emailContent,
      senderName: 'Alice',
      senderEmailAddress: 'alice@example.com',
      dateTime: '2026-09-25',
      fromPrefix: 'From',
      toPrefix: 'To',
      ccPrefix: 'Cc',
      bccPrefix: 'Bcc',
      replyToPrefix: 'Reply to',
      titleAttachment: 'attachments',
      attachmentIcon: '',
      toAddress: 'bob@example.com',
    );
  }

  group('PreviewEmlFileUtils.generatePreviewEml', () {
    test('should scope the email styles to the email body', () {
      final document = parse(generatePreviewEml(
        '<style>* { font-family: "Comic Sans MS" !important }</style><div>Hi</div>',
      ));

      final emailStyles = document.querySelectorAll('.email-body style');

      expect(emailStyles, hasLength(1));
      expect(
        emailStyles.single.text,
        '@scope (.email-body) {\n* { font-family: "Comic Sans MS" !important }\n}',
      );
    });

    test('should prevent the email styles from escaping the email body scope', () {
      final document = parse(generatePreviewEml(
        '<style>} .sender-email { display: none }</style>',
      ));

      expect(
        document.querySelector('.email-body style')!.text,
        '@scope (.email-body) {\n  .sender-email { display: none }\n}',
      );
    });

    test('should keep the app styles unscoped', () {
      final document = parse(generatePreviewEml('<div>Hi</div>'));

      expect(document.head!.querySelector('style')!.text, isNot(contains('@scope')));
    });
  });
}
