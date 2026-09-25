import 'package:core/data/model/preview_attachment.dart';
import 'package:core/utils/preview_eml_file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';

void main() {
  const injected = '<img src=x onerror="alert(1)">';

  String generate({
    String senderEmailAddress = 'bob@example.com',
    String? toAddress,
    String dateTime = 'today',
    List<PreviewAttachment>? listAttachment,
  }) {
    return PreviewEmlFileUtils().generatePreviewEml(
      appName: 'Twake Mail',
      ownEmailAddress: 'alice@example.com',
      subjectPrefix: 'Subject',
      subject: 'Hello',
      emailContent: '<p>Body</p>',
      senderName: 'Bob',
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
