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
    List<PreviewAttachment>? listAttachment,
  }) {
    return PreviewEmlFileUtils().generatePreviewEml(
      appName: 'Twake Mail',
      ownEmailAddress: 'alice@example.com',
      subjectPrefix: 'Subject',
      subject: subject,
      emailContent: '<p>Body</p>',
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
}
