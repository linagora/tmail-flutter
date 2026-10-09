import 'package:core/data/model/preview_attachment.dart';
import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';

void main() {
  const injected = '<img src=x onerror="alert(1)">';

  String generate({
    String subject = 'Hello',
    String senderName = 'Bob',
    String senderEmailAddress = 'bob@example.com',
    String? toAddress,
    String dateTime = 'today',
    String emailContent = '<p>Body</p>',
    List<PreviewAttachment>? listAttachment,
  }) {
    return PreviewEmlFileUtils().generatePreviewEml(
      appName: 'Twake Mail',
      ownEmailAddress: 'alice@example.com',
      subjectPrefix: 'Subject',
      subject: subject,
      emailContent: emailContent,
      senderName: senderName,
      senderEmailAddress: senderEmailAddress,
      dateTime: dateTime,
      fromPrefix: 'From',
      toPrefix: 'To',
      ccPrefix: 'Cc',
      bccPrefix: 'Bcc',
      replyToPrefix: 'Reply to',
      titleAttachment: 'attachment',
      attachmentIcon: '',
      toAddress: toAddress,
      listAttachment: listAttachment,
    );
  }

  group('PreviewEmlFileUtils.generatePreviewEml — header escaping', () {
    test('SHOULD NOT turn the sender address into markup', () {
      final document = parse(generate(senderEmailAddress: injected));

      expect(document.querySelectorAll('[onerror]'), isEmpty);
      expect(document.querySelector('.sender-email')!.text, contains(injected));
    });

    test('SHOULD NOT turn recipient display names into markup', () {
      final document = parse(generate(toAddress: '"$injected" <a@b.c>'));

      expect(document.querySelectorAll('[onerror]'), isEmpty);
      expect(document.querySelector('.recipients')!.text, contains(injected));
    });

    test('SHOULD NOT turn the date into markup', () {
      final document = parse(generate(dateTime: injected));

      expect(document.querySelectorAll('[onerror]'), isEmpty);
    });

    test('SHOULD NOT turn the subject or page title into markup', () {
      const breakout = '</title>$injected';
      final document = parse(generate(subject: breakout));

      expect(document.querySelectorAll('[onerror]'), isEmpty);
      expect(document.querySelector('.email-subject')!.text, contains(breakout));
      expect(document.querySelector('title')!.text, contains(breakout));
    });

    test('SHOULD NOT turn the sender name into markup', () {
      final document = parse(generate(senderName: injected));

      expect(document.querySelectorAll('[onerror]'), isEmpty);
      expect(document.querySelector('.sender')!.text, contains(injected));
    });

    test('SHOULD NOT turn the sender avatar letters into markup', () {
      // A name with at most one letter is shown as its first two raw
      // characters: unescaped, `<!` opens a comment that eats the `</div>`.
      final document = parse(generate(senderName: '<!'));

      expect(document.querySelector('.circle')!.text, '<!');
    });

    for (final link in <String?>['attachment:blobId?name=x', null]) {
      test('SHOULD NOT turn the attachment name into markup WHEN link is $link', () {
        final document = parse(generate(listAttachment: [
          PreviewAttachment(
            iconBase64Data: '',
            name: injected,
            size: '1 KB',
            link: link,
          ),
        ]));

        expect(document.querySelector('a.attachment-item') != null, link != null);
        expect(document.querySelectorAll('[onerror]'), isEmpty);
        expect(document.querySelector('.file-name')!.text, injected);
      });
    }

    test('SHOULD NOT allow the attachment link to break out of href', () {
      final document = parse(generate(listAttachment: [
        PreviewAttachment(
          iconBase64Data: '',
          name: 'file',
          size: '1 KB',
          link: 'https://example.com/x" onmouseover="alert(1)',
        ),
      ]));

      final link = document.querySelector('a.attachment-item')!;
      expect(link.attributes.containsKey('onmouseover'), isFalse);
      expect(link.attributes['href'], 'https://example.com/x" onmouseover="alert(1)');
    });
  });

  group('PreviewEmlFileUtils.generatePreviewEml — mail style scoping', () {
    test('should scope the email styles to the email body', () {
      final document = parse(generate(
        emailContent: '<style>* { font-family: "Comic Sans MS" !important }</style><div>Hi</div>',
      ));

      final emailStyles = document.querySelectorAll('.email-body style');

      expect(emailStyles, hasLength(1));
      expect(
        emailStyles.single.text,
        '@scope (.email-body) {\n* { font-family: "Comic Sans MS" !important }\n}',
      );
    });

    test('should prevent the email styles from escaping the email body scope', () {
      final document = parse(generate(
        emailContent: '<style>} .sender-email { display: none }</style>',
      ));

      expect(
        document.querySelector('.email-body style')!.text,
        '@scope (.email-body) {\n  .sender-email { display: none }\n}',
      );
    });

    test('should keep the app styles unscoped', () {
      final document = parse(generate(emailContent: '<div>Hi</div>'));

      expect(document.head!.querySelector('style')!.text, isNot(contains('@scope')));
    });

    test('should not let a style end tag forged inside the email styles inject HTML', () {
      final document = parse(generate(
        emailContent: '<style></style}><img src=x onerror="alert(1)"></style><div>Hi</div>',
      ));

      expect(document.querySelectorAll('img[onerror]'), isEmpty);
    });

    // A mail can still pull its own body up with a negative margin and paint
    // a fake sender, subject or attachment over the app-generated parts; they
    // must stack above it.
    test('should stack the subject, header and attachments above the email body', () {
      final document = parse(generate(emailContent: '<div>Hi</div>'));
      final appCss = document.head!.querySelector('style')!.text;

      for (final selector in ['.email-subject', '.email-header', '.attachments']) {
        final declarations = RegExp(r'([^{}]+)\{([^}]*)\}')
            .allMatches(appCss)
            .where((rule) => rule.group(1)!.split(',').map((part) => part.trim()).contains(selector))
            .map((rule) => rule.group(2)!)
            .join();

        expect(declarations, contains('position: relative'), reason: selector);
        expect(declarations, contains('z-index: 1'), reason: selector);
        expect(declarations, contains('background'), reason: selector);
      }
    });

    // Email styles can restyle the email body itself (`body` becomes the scope
    // root), but not its layer: whatever z-index they set stays below the header.
    test('should keep the email body inside a stacking layer below the header', () {
      final document = parse(generate(emailContent: '<div>Hi</div>'));
      final appCss = document.head!.querySelector('style')!.text;
      final layerRule = RegExp(r'\.email-body-layer\s*\{([^}]*)\}').firstMatch(appCss)!.group(1)!;

      expect(document.querySelector('.email-body')!.parent!.classes, contains('email-body-layer'));
      expect(layerRule, contains('position: relative'));
      expect(layerRule, contains('z-index: 0'));
    });
  });
}
