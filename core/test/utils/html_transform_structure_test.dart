import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;

import '../fixtures/html_emails/html_email_corpus.g.dart';
import '../fixtures/html_emails/html_email_corpus_fixture.dart';
import 'html/html_content_preservation.dart';
import 'html_pipeline_registry.dart';
import 'html_transform_text_html_test.mocks.dart';

/// Small inputs that probe one transformer each; real-email shapes come from
/// the shared corpus in `test/fixtures/html_emails`.
const _simpleTable = '<table>'
    '<tr><th>Name</th><th>Email</th></tr>'
    '<tr><td>Alice</td><td>alice@example.com</td></tr>'
    '</table>';

const _xss = '<div>'
    '<script>document.cookie="stolen";</script>'
    '<img src=x onerror="alert(1)">'
    '<svg><script>alert(\'svg\')</script></svg>'
    '<a href="javascript:void(0)" onclick="alert(1)">Click</a>'
    '<p onmouseover="alert(1)">Hover</p>'
    '<p>Valid content after XSS.</p>'
    '</div>';

const _signature = '<div class="tmail-signature">Kind regards</div>';

/// The corpus email at `test/fixtures/html_emails/<category>/<name>.html`.
String _corpus(String category, String name) => htmlEmailCorpus
    .singleWhere((HtmlEmailCorpusFixture f) => f.category == category && f.name == name)
    .html;

void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  Future<String> transform(
    String content,
    TransformConfiguration configuration,
  ) =>
      htmlTransform.transformToHtml(
        htmlContent: content,
        transformConfiguration: configuration,
      );

  bool hasEventHandler(String html) {
    final document = parse(html);
    return document
        .querySelectorAll('*')
        .any(
          (element) => element.attributes.keys.any(
            (name) => name.toString().toLowerCase().startsWith('on'),
          ),
        );
  }

  group('HtmlTransform structure — preview', () {
    final config = TransformConfiguration.forPreviewEmail();

    test('adds overflow-wrap on table cells', () async {
      final out = await transform(_simpleTable, config);
      final style = parse(out).querySelector('td')?.attributes['style'] ?? '';
      expect(style, contains('overflow-wrap'));
    });

    test('keeps RTL text', () async {
      final source = _corpus('scripts_languages', 'rtl_arabic');
      expect(bodyWordPreservation(source, await transform(source, config)), 1);
    });

    test('keeps Outlook MsoNormal text', () async {
      final source = _corpus('sending_clients', 'outlook_desktop');
      expect(bodyWordPreservation(source, await transform(source, config)), 1);
    });

    test('keeps wide pre text', () async {
      final source = _corpus('layout_stress', 'wide_pre');
      expect(bodyWordPreservation(source, await transform(source, config)), 1);
    });
  });

  group('HtmlTransform XSS — raw-input configs', () {
    for (final row in htmlPipelineRegistry().where((row) => row.takesHtml)) {
      if (row.trust != HtmlPipelineTrust.raw &&
          !(row.trust == HtmlPipelineTrust.user &&
              row.wiring == HtmlPipelineWiring.sanitizes)) {
        continue;
      }

      test('${row.name} strips script, onerror, javascript href', () async {
        final out = await transform(_xss, row.build());
        expect(out, isNot(contains('<script')));
        expect(out, isNot(contains('javascript:')));
        expect(hasEventHandler(out), isFalse);
        expect(out, contains('Valid content'));
      }, skip: row.knownGap);
    }
  });

  group('HtmlTransform snapshots — canonical fixtures', () {
    test('newsletter keeps tables and https image', () async {
      final source = parse(_corpus('newsletter_builders', 'mailchimp'));
      final out = parse(await transform(
        source.outerHtml,
        TransformConfiguration.forPreviewEmail(),
      ));
      List<String?> httpsImages(Document document) => [
            for (final img in document.querySelectorAll('img'))
              if (img.attributes['src']?.startsWith('https://') == true) img.attributes['src'],
          ];
      expect(out.querySelectorAll('table'), hasLength(source.querySelectorAll('table').length));
      expect(httpsImages(out), allOf(isNotEmpty, httpsImages(source)));
    });

    test('nested quotes stay nested after preview', () async {
      final source = _corpus('quoting_threads', 'nested_blockquote');
      final out = await transform(source, TransformConfiguration.forPreviewEmail());
      expect(parse(out).querySelectorAll('blockquote'), hasLength(3));
    });

    test('draft reload keeps Drive card contenteditable', () async {
      final card = FileLinkCardHtmlBuilder.buildFileLinkCard(
        const FileLinkCardContent(
          href: 'https://drive.example.com/file',
          title: 'file.pdf',
          actionLabel: 'Open',
          iconZoneHtml: '',
        ),
      );
      final html = '$_signature$card';
      final out = await transform(
        html,
        TransformConfiguration.forEditDraftsEmail(),
      );
      expect(out, contains('contenteditable="false"'));
      expect(out, contains('tmail-file-link-card'));
    });

    test('empty-reply sanitizer keeps signature class for SignatureTransformer', () async {
      const html = '<div class="tmail-signature">Best regards</div>'
          '<p>Quoted body</p>';
      final out = await transform(
        html,
        TransformConfiguration.forReplyForwardEmptyEmail(),
      );
      expect(out, contains('tmail-signature-blocked'));
      expect(out, contains('Best regards'));
    });
  });
}
