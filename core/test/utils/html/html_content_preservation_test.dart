import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/html_emails/html_email_corpus.g.dart';
import '../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../html_transform_text_html_test.mocks.dart';
import 'html_content_preservation.dart';

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
      for (final entry in displayPipelines.entries) {
        test('${fixture.category}/${fixture.name} through ${entry.key}', () async {
          final out = await htmlTransform.transformToHtml(
            htmlContent: fixture.html,
            transformConfiguration: entry.value(),
          );
          if (fixture.allowEmptyBody) return;
          expect(
            bodyWordPreservation(fixture.html, out),
            greaterThanOrEqualTo(fixture.minPreservation),
          );
          expect(bodyLinkCount(out), bodyLinkCount(fixture.html));
        });
      }
    }
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
