import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/dom/sanitize_nested_style_transformer.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import 'html_transform_text_html_test.mocks.dart';

void main() {
  group('SanitizeNestedStyleTransformer.sanitizeNestedStylesheet', () {
    String sanitize(String css) =>
        SanitizeNestedStyleTransformer.sanitizeNestedStylesheet(css);

    test('SHOULD keep @media blocks and their allowed declarations', () {
      final out = sanitize('@media (max-width: 600px) { .a { color: red; } }');

      expect(out, contains('@media (max-width: 600px)'));
      expect(out, contains('color: red'));
    });

    test('SHOULD drop properties outside the allow-list inside @media', () {
      final out = sanitize(
        '@media screen { .overlay { position: fixed; z-index: 9999; color: red; } }',
      );

      expect(out, isNot(contains('position')));
      expect(out, isNot(contains('z-index')));
      expect(out, contains('color: red'));
    });

    test('SHOULD drop at-rules other than @media', () {
      final out = sanitize(
        '@supports (display: grid) { .a { color: red; } } '
        '@keyframes k { from { opacity: 0; } to { opacity: 1; } } '
        '@font-face { font-family: x; src: url(https://tracker.example/f.woff); }',
      );

      expect(out, isNot(contains('@supports')));
      expect(out, isNot(contains('@keyframes')));
      expect(out, isNot(contains('@font-face')));
      expect(out, isNot(contains('tracker.example')));
    });

    test('SHOULD sanitize plain rules next to nested blocks', () {
      final out = sanitize(
        '.a { position: absolute; color: blue; } @media print { .b { color: red; } }',
      );

      expect(out, contains('.a'));
      expect(out, contains('color: blue'));
      expect(out, isNot(contains('position')));
      expect(out, contains('@media print'));
    });

    test('SHOULD drop @media nested inside @media', () {
      final out = sanitize(
        '@media screen { @media (min-width: 1px) { .a { position: fixed; } } }',
      );

      expect(out, isNot(contains('position')));
    });

    test('SHOULD return an empty string for unbalanced input', () {
      expect(sanitize('@media screen { .a { color: red;'), isEmpty);
    });
  });

  group('SanitizeNestedStyleTransformer in the viewer pipeline', () {
    test('SHOULD sanitize nested CSS of an email rendered on web', () async {
      final htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());

      final out = await htmlTransform.transformToHtml(
        htmlContent: '<style>@media screen { .x { position: fixed; top: 0; color: red; } }</style>'
            '<p class="x">Hello</p>',
        transformConfiguration: TransformConfiguration.forPreviewEmailOnWeb(),
      );

      expect(out, contains('Hello'));
      expect(out, isNot(contains('position')));
    });
  });
}
