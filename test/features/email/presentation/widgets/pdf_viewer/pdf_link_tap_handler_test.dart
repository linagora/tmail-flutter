import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/pdf_viewer/pdf_link_tap_handler.dart';

void main() {
  group('PdfLinkTapHandler::handle', () {
    late List<String> launchedLinks;
    late List<Uri> mailtoLinks;

    PdfLinkTapHandler buildHandler({bool withMailtoAction = true}) {
      return PdfLinkTapHandler(
        launchLinkAction: launchedLinks.add,
        mailtoAction: withMailtoAction ? mailtoLinks.add : null,
      );
    }

    setUp(() {
      launchedLinks = [];
      mailtoLinks = [];
    });

    group('Should launch the link', () {
      final webLinks = {
        'http://example.com/page': 'http://example.com/page',
        'https://example.com/page?q=1#top': 'https://example.com/page?q=1#top',
        'HTTPS://Example.com/page': 'https://example.com/page',
      };

      webLinks.forEach((link, expectedLaunchedLink) {
        test('When the link is "$link"', () {
          buildHandler().handle(Uri.parse(link));

          expect(launchedLinks, [expectedLaunchedLink]);
          expect(mailtoLinks, isEmpty);
        });
      });
    });

    test(
      'Should open the composer and not launch the link\n'
      'When a mailto link is tapped and a mailto action is set',
    () {
      final uri = Uri.parse('mailto:alice@example.com?subject=Hello');

      buildHandler().handle(uri);

      expect(mailtoLinks, [uri]);
      expect(launchedLinks, isEmpty);
    });

    test(
      'Should launch the mailto link\n'
      'When a mailto link is tapped and no mailto action is set',
    () {
      buildHandler(withMailtoAction: false)
        .handle(Uri.parse('mailto:alice@example.com'));

      expect(launchedLinks, ['mailto:alice@example.com']);
      expect(mailtoLinks, isEmpty);
    });

    group('Should not launch the link nor open the composer', () {
      final unsafeLinks = [
        'javascript:alert(document.cookie)',
        'JavaScript:alert(1)',
        'vbscript:msgbox(1)',
        'data:text/html,<script>alert(1)</script>',
        'file:///etc/passwd',
        'blob:https://example.com/uuid',
        '//example.com/scheme-relative',
        'relative/path',
      ];

      for (final link in unsafeLinks) {
        test('When the link is "$link"', () {
          buildHandler().handle(Uri.parse(link));

          expect(launchedLinks, isEmpty);
          expect(mailtoLinks, isEmpty);
        });
      }
    });
  });
}
