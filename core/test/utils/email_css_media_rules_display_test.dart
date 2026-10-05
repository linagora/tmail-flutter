import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import 'html_transform_text_html_test.mocks.dart';

/// Received emails rely on `@media` rules for their phone layout and dark
/// mode. Sanitizing a stylesheet must keep those rules, including when the
/// sheet contains CSS comments, as professional templates do.
void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  final pipelines = <String, TransformConfiguration Function()>{
    'web viewer': TransformConfiguration.forPreviewEmailOnWeb,
    'mobile viewer': TransformConfiguration.forPreviewEmail,
    'standard': () => TransformConfiguration.standardConfiguration,
  };

  String stylesOf(String html) =>
      RegExp(r'<style[^>]*>(.*?)</style>', dotAll: true)
          .allMatches(html)
          .map((m) => m.group(1)!)
          .join('\n');

  // Trimmed from the Cerberus responsive template (emailmonday/Cerberus).
  const cerberusLikeSheet = '''
    /* What it does: Stops email clients resizing small text. */
    * { -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; }
    /* What it does: Centers email on Android 4.4 */
    div[style*="margin: 16px 0"] { margin: 0 !important; }
    .email-container { max-width: 600px; margin: 0 auto; }
    /* What it does: Forces table cells into full-width rows on narrow screens. */
    @media screen and (max-width: 600px) {
      .email-container { width: 100% !important; margin: auto !important; }
      .stack-column { display: block !important; width: 100% !important; max-width: 100% !important; }
    }
    /* What it does: Dark mode colors. */
    @media (prefers-color-scheme: dark) {
      .email-bg { background: #111111 !important; }
      p { color: #F7F7F9 !important; }
    }''';

  pipelines.forEach((name, create) {
    group('$name keeps @media rules of received emails', () {
      test('responsive @media preceded by a CSS comment', () async {
        final out = stylesOf(await htmlTransform.transformToHtml(
          htmlContent: '<style>.a{color:red} /* phones */ @media (max-width:600px){.a{width:100%}}</style><p class="a">x</p>',
          transformConfiguration: create(),
        ));

        expect(out, contains('@media'));
        expect(out, contains('max-width'));
      });

      test('dark mode @media preceded by a CSS comment', () async {
        final out = stylesOf(await htmlTransform.transformToHtml(
          htmlContent: '<style>body{color:#111} /* dark */ @media (prefers-color-scheme: dark){body{color:#eee}}</style><p>x</p>',
          transformConfiguration: create(),
        ));

        expect(out, contains('prefers-color-scheme'));
        expect(out, contains('#eee'));
      });

      test('commented template keeps both its phone layout and dark mode blocks', () async {
        final out = stylesOf(await htmlTransform.transformToHtml(
          htmlContent: '<style>$cerberusLikeSheet</style><div class="email-container"><p>x</p></div>',
          transformConfiguration: create(),
        ));

        expect(RegExp('@media').allMatches(out).length, 2);
        expect(out, contains('.stack-column'));
        expect(out, contains('#111111'));
      });

      test('uncommented responsive and dark mode @media', () async {
        final out = stylesOf(await htmlTransform.transformToHtml(
          htmlContent: '<style>.a{color:red} @media (max-width:600px){.a{width:100%}} @media (prefers-color-scheme: dark){.a{color:#eee}}</style><p class="a">x</p>',
          transformConfiguration: create(),
        ));

        expect(RegExp('@media').allMatches(out).length, 2);
      });
    });
  });
}
