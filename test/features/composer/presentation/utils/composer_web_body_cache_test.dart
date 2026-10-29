import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_web_body_cache.dart';

import '../fixtures/code_view_html_fixtures.dart';

void main() {
  group('ComposerWebBodyCache', () {
    late ComposerWebBodyCache cache;

    setUp(() => cache = ComposerWebBodyCache());

    test('sanitizes a code view change before it is read', () {
      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: true);

      final body = cache.read()!.toLowerCase();
      expect(body, isNot(contains('onerror')));
      expect(body, isNot(contains('<script')));
      expect(body, isNot(contains('javascript:')));
      expect(body, contains('visible text'));
    });

    test('keeps the sanitized body for later reads', () {
      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: true);

      final first = cache.read();

      expect(cache.read(), first);
    });

    test('keeps an editor change made outside code view as is', () {
      cache.onEditorChange(youtubeIframeEmbed, inCodeView: false);

      expect(cache.read(), youtubeIframeEmbed);
    });

    test('keeps content set by the app as is, even after a code view change', () {
      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: true);

      cache.setTrusted(youtubeIframeEmbed);

      expect(cache.read(), youtubeIframeEmbed);
    });

    test('sanitizes again when code view changes the body after a read', () {
      cache.onEditorChange(benignComposerHtml, inCodeView: false);
      cache.read();

      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: true);

      expect(cache.read()!.toLowerCase(), isNot(contains('onerror')));
    });

    test('returns null once cleared', () {
      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: true);

      cache.setTrusted(null);

      expect(cache.read(), isNull);
    });
  });
}
