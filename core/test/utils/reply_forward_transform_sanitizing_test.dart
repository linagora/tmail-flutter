import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import 'html_transform_text_html_test.mocks.dart';

void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  final configurations = <String, TransformConfiguration Function()>{
    'forReplyForwardEmail': TransformConfiguration.forReplyForwardEmail,
    'forReplyForwardEmptyEmail': TransformConfiguration.forReplyForwardEmptyEmail,
  };

  configurations.forEach((name, create) {
    group('$name (quoted content inserted into the composer)', () {
      test('SHOULD include the HTML sanitizer', () {
        expect(
          create().textTransformers
              .whereType<StandardizeHtmlSanitizingTransformers>(),
          isNotEmpty,
        );
      });

      test('SHOULD remove event handler attributes', () async {
        final out = await htmlTransform.transformToHtml(
          htmlContent: '<p>Hello</p><img src="https://example.com/a.png" onerror="alert(1)">',
          transformConfiguration: create(),
        );

        expect(out, contains('Hello'));
        expect(out.toLowerCase(), isNot(contains('onerror')));
      });

      test('SHOULD remove script elements', () async {
        final out = await htmlTransform.transformToHtml(
          htmlContent: '<div>Body</div><script>alert(1)</script>',
          transformConfiguration: create(),
        );

        expect(out, contains('Body'));
        expect(out.toLowerCase(), isNot(contains('<script')));
      });

      test('SHOULD remove javascript: links', () async {
        final out = await htmlTransform.transformToHtml(
          htmlContent: '<a href="javascript:alert(1)">link</a>',
          transformConfiguration: create(),
        );

        expect(out.toLowerCase(), isNot(contains('javascript:')));
      });

      test('SHOULD still block the quoted signature', () async {
        final out = await htmlTransform.transformToHtml(
          htmlContent: '<div class="tmail-signature">Signature</div>',
          transformConfiguration: create(),
        );

        expect(out, contains('tmail-signature-blocked'));
      });
    });
  });
}
