import 'package:core/data/model/print_attachment.dart';
import 'package:core/utils/html/html_interaction.dart';
import 'package:core/utils/print_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';

void main() {
  group('PrintUtils.createSenderElement', () {
    final printUtils = PrintUtils();

    test('escapes the sender email address before interpolating it into the printed document', () {
      final element = printUtils.createSenderElement(
        fromPrefix: 'From',
        senderName: 'Alice',
        senderEmailAddress: '"><script>alert(1)</script>',
        dateTime: '2026-09-28',
      );

      final html = element!.outerHtml;
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });

    test('escapes the date/time string before interpolating it into the printed document', () {
      final element = printUtils.createSenderElement(
        fromPrefix: 'From',
        senderName: 'Alice',
        senderEmailAddress: 'alice@example.com',
        dateTime: '"><script>alert(1)</script>',
      );

      final html = element!.outerHtml;
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });

    test('escapes the sender name before interpolating it into the printed document', () {
      final element = printUtils.createSenderElement(
        fromPrefix: 'From',
        senderName: '"><script>alert(1)</script>',
        senderEmailAddress: 'alice@example.com',
        dateTime: '2026-09-28',
      );

      final html = element!.outerHtml;
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });
  });

  group('PrintUtils.printEmail', () {
    test('does not turn the subject, title or attachment name into markup', () async {
      const injected = '</title><img src=x onerror="alert(1)">';
      late String printed;
      final printUtils = PrintUtils(openHtmlDocument: (html) => printed = html);

      await printUtils.printEmail(
        appName: 'Twake Mail',
        userName: 'alice@example.com',
        subject: injected,
        emailContent: '<p>Body</p>',
        senderName: 'Bob',
        senderEmailAddress: 'bob@example.com',
        dateTime: 'today',
        fromPrefix: 'From',
        toPrefix: 'To',
        ccPrefix: 'Cc',
        bccPrefix: 'Bcc',
        replyToPrefix: 'Reply to',
        titleAttachment: 'attachment',
        listAttachment: [PrintAttachment(iconBase64Data: '', name: injected, size: '1 KB')],
      );

      final document = parse(printed);
      expect(document.querySelectorAll('[onerror]'), isEmpty);
      expect(document.querySelector('title')!.text, 'Twake Mail - $injected');
      expect(document.querySelector('.main-content font b')!.text, injected);
      expect(document.querySelector('.attachments b:not([style])')!.text, injected);
    });

    test('stamps the print script and leaves a script in the email content', () async {
      const nonce = 'printNonce_1';
      const emailScript = '<p>Body</p><script>alert(1)</script>';
      final stamped = await _printDocument(emailContent: emailScript, scriptNonce: nonce);
      final baseline = await _printDocument(emailContent: emailScript);

      expect(stamped, contains('<script nonce="$nonce"'));
      expect(stamped, contains('window.print'));
      expect(stamped, contains('<script>alert(1)</script>'));
      expect(baseline, isNot(contains('nonce=')));
      expect(await _printDocument(emailContent: emailScript, scriptNonce: ''), baseline);
      expect(await _printDocument(emailContent: emailScript, scriptNonce: 'bad nonce'), baseline);
      expect(
        baseline.contains(HtmlInteraction.scriptHandleInvokePrinterOnBrowser.trim()),
        isTrue,
      );
    });
  });
}

Future<String> _printDocument({
  required String emailContent,
  String? scriptNonce,
}) async {
  late String printed;
  final printUtils = PrintUtils(openHtmlDocument: (html) => printed = html);
  await printUtils.printEmail(
    appName: 'Twake Mail',
    userName: 'alice@example.com',
    subject: 'Subject',
    emailContent: emailContent,
    senderName: 'Bob',
    senderEmailAddress: 'bob@example.com',
    dateTime: 'today',
    fromPrefix: 'From',
    toPrefix: 'To',
    ccPrefix: 'Cc',
    bccPrefix: 'Bcc',
    replyToPrefix: 'Reply to',
    titleAttachment: 'attachment',
    scriptNonce: scriptNonce,
  );
  return printed;
}
