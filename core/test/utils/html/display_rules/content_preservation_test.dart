import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/html_emails/html_email_corpus.g.dart';
import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../../html_transform_text_html_test.mocks.dart';
import 'content_preservation.dart';

/// G-preserve: the display pipelines keep the body words and the links of
/// every fixture (measured on the transform output).
void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  final displayPipelines = <String, TransformConfiguration Function()>{
    'forPreviewEmail': TransformConfiguration.forPreviewEmail,
    'forPreviewEmailOnWeb': TransformConfiguration.forPreviewEmailOnWeb,
    'standardConfiguration': () => TransformConfiguration.standardConfiguration,
  };

  group('content preservation', () {
    for (final fixture in htmlEmailCorpus) {
      final pipelines = fixture.isPlainText
          ? {'forPlainTextEmail': TransformConfiguration.forPlainTextEmail}
          : displayPipelines;
      for (final entry in pipelines.entries) {
        test('${fixture.category}/${fixture.name} through ${entry.key}', () async {
          final out = fixture.isPlainText
              ? htmlTransform.transformToTextPlain(
                  content: fixture.html,
                  transformConfiguration: entry.value(),
                )
              : await htmlTransform.transformToHtml(
                  htmlContent: fixture.html,
                  transformConfiguration: entry.value(),
                );
          if (fixture.allowEmptyBody) return;
          if (fixture.isPlainText) {
            // Autolinking adds links, so only the words are compared.
            expect(
              plainTextWordPreservation(fixture.html, out),
              greaterThanOrEqualTo(fixture.minPreservation),
            );
            return;
          }
          expect(
            bodyWordPreservation(fixture.html, out),
            greaterThanOrEqualTo(fixture.minPreservation),
          );
          expect(bodyLinkCount(out), bodyLinkCount(fixture.html));
        });
      }
    }
  });

  test('plain-text words survive escaping and autolinking', () async {
    const source = 'Hi <b>there</b> & see https://example.com/a now';
    final out = htmlTransform.transformToTextPlain(
      content: source,
      transformConfiguration: TransformConfiguration.forPlainTextEmail(),
    );
    expect(plainTextWordPreservation(source, out), 1);
    expect(plainTextWordPreservation(source, 'Hi now'), lessThan(0.95));
  });

  test('dropping visible table-cell text fails preservation', () {
    const source =
        '<table><tr><td>alpha beta gamma delta epsilon</td><td>keep</td></tr></table>';
    const dropped = '<table><tr><td>keep</td></tr></table>';
    expect(bodyWordPreservation(source, dropped), lessThan(0.95));
  });

  test('corpus covers every display category', () {
    expect(
      htmlEmailCorpus.map((HtmlEmailCorpusFixture f) => f.category).toSet(),
      containsAll([
        'sending_clients',
        'newsletter_builders',
        'notifications',
        'quoting_threads',
        'scripts_languages',
        'layout_stress',
        'media',
        'edge',
      ]),
    );
  });
}
