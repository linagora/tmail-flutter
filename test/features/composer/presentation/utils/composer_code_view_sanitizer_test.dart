import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_code_view_sanitizer.dart';

import '../fixtures/code_view_html_fixtures.dart';

void main() {
  const sanitizer = ComposerCodeViewSanitizer();

  String sanitize(String html) => sanitizer.sanitize(html);

  group('ComposerCodeViewSanitizer security', () {
    test('strips the GHSA-73vq-c7p5-pvp4 embed-code payload', () {
      final out = sanitize(ghsaEmbedCodeXssPayload).toLowerCase();

      expect(out, isNot(contains('<script')));
      expect(out, isNot(contains('onerror')));
      expect(out, isNot(contains('onload')));
      expect(out, isNot(contains('javascript:')));
      expect(out, contains('clickme'));
      expect(out, contains('visible text'));
    });

    test('strips a YouTube iframe embed and keeps surrounding text', () {
      final out = sanitize(youtubeIframeEmbed).toLowerCase();

      expect(out, isNot(contains('<iframe')));
      expect(out, isNot(contains('youtube.com/embed')));
      expect(out, contains('watch this'));
    });
  });

  group('ComposerCodeViewSanitizer characterization', () {
    test(
      'keeps cid images, public assets, tables, https links and Drive cards',
      () {
        final out = sanitize(benignComposerHtml);

        expect(out, contains('src="cid:img-1"'));
        expect(out, contains('public-asset-id="sig1"'));
        expect(out, contains('data-filename="sig.png"'));
        expect(out, contains('data-mimetype="image/png"'));
        expect(out, contains('<td>cell</td>'));
        expect(out, contains('href="https://example.com"'));
        expect(out, contains('class="tmail-file-link-card"'));
        expect(out, contains('contenteditable="false"'));
        expect(out, contains('visible text'));
      },
    );
  });
}
