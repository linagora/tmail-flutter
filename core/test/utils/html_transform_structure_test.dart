import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' show parse;

import '../../../test/fixtures/html_email_corpus.dart';
import 'html_transform_text_html_test.mocks.dart';
import 'transform_configuration_contract_test.dart';

void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
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

    test('preserves nested table count on a newsletter', () async {
      final out = await transform(
        HtmlEmailCorpus.htmlNewsletterNestedTables,
        config,
      );
      expect(parse(out).querySelectorAll('table').length, 2);
    });

    test('adds overflow-wrap on table cells', () async {
      final out = await transform(HtmlEmailCorpus.htmlTableSimple, config);
      final style = parse(out).querySelector('td')?.attributes['style'] ?? '';
      expect(style, contains('overflow-wrap'));
    });

    test('keeps RTL text', () async {
      final out = await transform(HtmlEmailCorpus.htmlRtlArabic, config);
      expect(out, contains('مرحبا'));
    });

    test('keeps Outlook MsoNormal text', () async {
      final out = await transform(HtmlEmailCorpus.htmlOutlookMso, config);
      expect(out, contains('Hello from Outlook'));
    });

    test('keeps nested quotes', () async {
      final out = await transform(
        HtmlEmailCorpus.htmlNestedQuotesThreeLevels,
        config,
      );
      expect(parse(out).querySelectorAll('blockquote').length, 3);
    });

    test('keeps wide pre text', () async {
      final out = await transform(HtmlEmailCorpus.htmlWidePre, config);
      expect(out, contains('abcdefghijklmnopqrstuvwxyz0123456789'));
    });
  });

  group('HtmlTransform XSS — raw-input configs', () {
    final rawConfigs = <String, TransformConfiguration>{
      'forPreviewEmail': TransformConfiguration.forPreviewEmail(),
      'forPreviewEmailOnWeb': TransformConfiguration.forPreviewEmailOnWeb(),
      'forDraftsEmail': TransformConfiguration.forDraftsEmail(),
      'forEditDraftsEmail': TransformConfiguration.forEditDraftsEmail(),
      'forRestoreEmail': TransformConfiguration.forRestoreEmail(),
      'forCalendarEvent': TransformConfiguration.forCalendarEvent(),
      'forAttachmentPreview': TransformConfiguration.forAttachmentPreview(),
      'standardConfiguration': TransformConfiguration.standardConfiguration,
    };

    for (final entry in rawConfigs.entries) {
      test('${entry.key} strips script, onerror, javascript href', () async {
        final out = await transform(HtmlEmailCorpus.htmlXssRich, entry.value);
        expect(out, isNot(contains('<script')));
        expect(out, isNot(contains('javascript:')));
        expect(hasEventHandler(out), isFalse);
        expect(out, contains('Valid content'));
      });
    }

    test(
      'forReplyForwardEmptyEmail strips XSS from raw server HTML',
      () async {
        final out = await transform(
          HtmlEmailCorpus.htmlXssRich,
          TransformConfiguration.forReplyForwardEmptyEmail(),
        );
        expect(out, isNot(contains('<script')));
        expect(hasEventHandler(out), isFalse);
      },
      skip: emptyReplySanitizerSkip,
    );
  });

  group('HtmlTransform snapshots — canonical fixtures', () {
    test('newsletter keeps tables and https image', () async {
      final out = await transform(
        HtmlEmailCorpus.htmlNewsletterNestedTables,
        TransformConfiguration.forPreviewEmail(),
      );
      final document = parse(out);
      expect(document.querySelectorAll('table'), hasLength(2));
      expect(
        document.querySelector('img')?.attributes['src'],
        'https://example.com/banner.png',
      );
    });

    test('nested quotes stay nested after preview', () async {
      final out = await transform(
        HtmlEmailCorpus.htmlNestedQuotesThreeLevels,
        TransformConfiguration.forPreviewEmail(),
      );
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
      final html = '${HtmlEmailCorpus.htmlSignatureAndDriveCard}$card';
      final out = await transform(
        html,
        TransformConfiguration.forEditDraftsEmail(),
      );
      expect(out, contains('contenteditable="false"'));
      expect(out, contains('tmail-file-link-card'));
    });
  });
}
