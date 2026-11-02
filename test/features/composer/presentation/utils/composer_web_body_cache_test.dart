import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_code_view_sanitizer.dart';
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

    test('sanitizes once per code view change, not on every read', () {
      final sanitizer = _CountingSanitizer();
      cache = ComposerWebBodyCache(sanitizer: sanitizer);
      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: true);

      cache.read();
      cache.read();

      expect(sanitizer.calls, 1);
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

    test('still sanitizes when a raw change lands after code view was left', () {
      cache.onEditorChange(benignComposerHtml, inCodeView: true);

      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: false);

      expect(cache.read()!.toLowerCase(), isNot(contains('onerror')));
    });

    test('still sanitizes a late raw change after a rebuild read cleared the dirty bit', () {
      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: true);
      expect(cache.read()!.toLowerCase(), isNot(contains('onerror')));

      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: false);

      expect(cache.read()!.toLowerCase(), isNot(contains('onerror')));
    });

    test('returns null once cleared', () {
      cache.onEditorChange(ghsaEmbedCodeXssPayload, inCodeView: true);

      cache.setTrusted(null);

      expect(cache.read(), isNull);
    });
  });
}

class _CountingSanitizer extends ComposerCodeViewSanitizer {
  int calls = 0;

  @override
  String sanitize(String html) {
    calls++;
    return super.sanitize(html);
  }
}
