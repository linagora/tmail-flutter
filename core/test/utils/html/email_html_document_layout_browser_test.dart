@TestOn('chrome')

import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/html_emails/html_email_corpus.g.dart';
import '../html_transform_text_html_test.mocks.dart';
import 'mobile_email_responsive_layout_fixture.dart';

void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  Future<String> transform(
    String html,
    TransformConfiguration configuration,
  ) =>
      htmlTransform.transformToHtml(
        htmlContent: html,
        transformConfiguration: configuration,
      );

  group('corpus layout through HtmlTransform', () {
    for (final fixture in htmlEmailCorpus) {
      test('${fixture.category}/${fixture.name} web 1280', () async {
        final transformed = await transform(
          fixture.html,
          TransformConfiguration.forPreviewEmailOnWeb(),
        );
        final hasQuote = transformed.contains('<blockquote');
        await withEmail(
          EmailFixture(
            transformed,
            viewportWidth: 1280,
            quoteToggle: fixture.expectQuote || hasQuote,
            includeMobileScript: false,
          ),
          (viewport) async {
            expect(viewport.overflowsHorizontally, isFalse);
            if (!fixture.allowEmptyBody) {
              expect(viewport.element('.tmail-content').textContent, isNotEmpty);
            }
            if (fixture.expectQuote || hasQuote) {
              expect(viewport.element('.quote-toggle-button'), isNotNull);
              expect(viewport.isQuoteVisible, isFalse);
              await viewport.expandQuote();
              expect(viewport.isQuoteVisible, isTrue);
            }
          },
        );
      });

      test('${fixture.category}/${fixture.name} mobile 360', () async {
        final transformed = await transform(
          fixture.html,
          TransformConfiguration.forPreviewEmail(),
        );
        final hasQuote = transformed.contains('<blockquote');
        await withEmail(
          EmailFixture(
            transformed,
            viewportWidth: 360,
            quoteToggle: fixture.expectQuote || hasQuote,
            includeMobileScript: true,
          ),
          (viewport) async {
            expect(viewport.overflowsHorizontally, isFalse);
            if (!fixture.allowEmptyBody) {
              expect(viewport.element('.tmail-content').textContent, isNotEmpty);
            }
            for (final img in viewport.images) {
              expect(
                img.getBoundingClientRect().width <= viewport.contentWidth + 1,
                isTrue,
              );
            }
          },
        );
      });
    }
  });
}
