import 'package:core/utils/html/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart';

void main() {
  group('HtmlUtils.generateHtmlDocument — restrictScriptsToNonce', () {
    const appScripts = '<script type="text/javascript">var a = 1;</script>'
        '<SCRIPT>var b = 2;</SCRIPT>';
    const untrustedContent = '<p>Hello</p><script>alert(1)</script>';

    test('SHOULD NOT add a CSP by default', () {
      final result = HtmlUtils.generateHtmlDocument(
        content: '<p>Hello</p>',
        javaScripts: appScripts,
      );

      expect(result, isNot(contains('Content-Security-Policy')));
    });

    test('SHOULD add a nonce-based CSP meta in <head>', () {
      final document = parse(HtmlUtils.generateHtmlDocument(
        content: '<p>Hello</p>',
        javaScripts: appScripts,
        restrictScriptsToNonce: true,
      ));

      final meta = document.head!.querySelector('meta[http-equiv="Content-Security-Policy"]');
      expect(meta, isNotNull);
      final policy = meta!.attributes['content']!;
      expect(policy, matches(RegExp(r"script-src 'nonce-[A-Za-z0-9_-]{16,}'")));
      expect(policy, contains("object-src 'none'"));
      expect(policy, contains("base-uri 'none'"));
      expect(policy, contains("form-action 'none'"));
    });

    test('SHOULD put the nonce on the application scripts only', () {
      final document = parse(HtmlUtils.generateHtmlDocument(
        content: untrustedContent,
        javaScripts: appScripts,
        restrictScriptsToNonce: true,
      ));

      final policy = document.head!
          .querySelector('meta[http-equiv="Content-Security-Policy"]')!
          .attributes['content']!;
      final nonce = RegExp(r"'nonce-([^']+)'").firstMatch(policy)!.group(1);

      final scripts = document.querySelectorAll('script');
      final contentScripts = document.querySelectorAll('.tmail-content script');
      final appScriptElements = scripts.where((s) => !contentScripts.contains(s));

      expect(appScriptElements, hasLength(2));
      for (final script in appScriptElements) {
        expect(script.attributes['nonce'], nonce);
      }
      for (final script in contentScripts) {
        expect(script.attributes.containsKey('nonce'), isFalse);
      }
    });

    test('SHOULD generate a different nonce for each document', () {
      expect(HtmlUtils.generateCspNonce(), isNot(HtmlUtils.generateCspNonce()));
    });
  });
}
