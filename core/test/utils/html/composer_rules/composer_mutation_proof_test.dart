import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/dom/add_lazy_loading_for_background_image_transformers.dart';
import 'package:core/presentation/utils/html_transformer/dom/block_code_transformers.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' show parse;

import '../../../fixtures/html_emails/html_email_corpus.g.dart';
import '../../../fixtures/html_emails/html_email_corpus_fixture.dart';
import '../../html_pipeline_registry.dart';
import '../display_rules/drop_tables_transformer.dart';
import 'composer_rules.dart';

/// Fixtures have no cid map, so the pipelines never download.
class _OfflineDioClient extends Fake implements DioClient {}

class _AppendMarkerTransformer extends TextTransformer {
  const _AppendMarkerTransformer();

  @override
  String process(String text, HtmlEscape htmlEscape) => '$text<span>.</span>';
}

Future<String> _transform(String html, TransformConfiguration config) =>
    HtmlTransform(_OfflineDioClient(), const HtmlEscape()).transformToHtml(
      htmlContent: html,
      transformConfiguration: config,
    );

HtmlEmailCorpusFixture _fixture(String id) => htmlEmailCorpus.singleWhere(
      (f) => '${f.category}/${f.name}' == id,
    );

/// Each composer rule passes unbroken and catches a deliberate test-only break.
void main() {
  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  TransformConfiguration draftsConfig() => htmlPipelineRegistry()
      .singleWhere((r) => r.name == 'forEditDraftsEmail-vm')
      .build();

  test('preservation catches dropped tables', () async {
    final config = draftsConfig();
    final fixture = _fixture('expect_checks/auto_scale_table');
    final out = await _transform(fixture.html, config);
    expect(preservationFailures(fixture, out), isEmpty);

    final broken = TransformConfiguration(
      config.domTransformers,
      [...config.textTransformers, const DropTablesTransformer()],
    );
    final brokenOut = await _transform(fixture.html, broken);
    expect(preservationFailures(fixture, brokenOut), isNotEmpty);
  });

  test('idempotence catches an appended marker', () async {
    final config = draftsConfig();
    final fixture = _fixture('expect_checks/full_display');
    final once = await _transform(fixture.html, config);
    final twice = await _transform(once, config);
    expect(idempotenceFailures(parse(once), parse(twice)), isEmpty);

    final broken = TransformConfiguration(
      config.domTransformers,
      [...config.textTransformers, const _AppendMarkerTransformer()],
    );
    final brokenOnce = await _transform(fixture.html, broken);
    final brokenTwice = await _transform(brokenOnce, broken);
    expect(idempotenceFailures(parse(brokenOnce), parse(brokenTwice)), isNotEmpty);
  });

  test('display-only leaks catches lazy background markup', () async {
    final config = draftsConfig();
    final fixture = _fixture('expect_checks/lazy_images');
    final out = await _transform(fixture.html, config);
    expect(displayOnlyLeaks(parse(fixture.html), parse(out)), isEmpty);

    final broken = TransformConfiguration(
      [...config.domTransformers, const AddLazyLoadingForBackgroundImageTransformer()],
      config.textTransformers,
    );
    final brokenOut = await _transform(fixture.html, broken);
    expect(displayOnlyLeaks(parse(fixture.html), parse(brokenOut)), isNotEmpty);
  });

  test('drive cards catches missing contenteditable protection', () async {
    final config = draftsConfig();
    final html = '<p>See</p>${FileLinkCardHtmlBuilder.buildFileLinkCard(
      const FileLinkCardContent(
        href: 'https://fixture.invalid/link/drive',
        title: 'report.pdf',
        actionLabel: 'Open',
        iconZoneHtml: '<div>PDF</div>',
      ),
    )}';
    final out = await _transform(html, config);
    expect(driveCardFailures(parse(out)), isEmpty);

    final broken = TransformConfiguration(
      config.domTransformers,
      [const StandardizeHtmlSanitizingTransformers()],
    );
    final brokenOut = await _transform(html, broken);
    expect(driveCardFailures(parse(brokenOut)), isNotEmpty);
  });

  test('line-height only catches block code styling', () async {
    final row = htmlPipelineRegistry()
        .singleWhere((r) => r.name == 'forComposerSignature');
    final config = row.build();
    const html = '<pre style="color:red">x</pre>';
    final out = await _transform(html, config);
    expect(lineHeightOnlyFailures(parse(html), parse(out)), isEmpty);

    final broken = TransformConfiguration(
      [...config.domTransformers, const BlockCodeTransformer()],
      config.textTransformers,
    );
    final brokenOut = await _transform(html, broken);
    expect(lineHeightOnlyFailures(parse(html), parse(brokenOut)), isNotEmpty);
  });
}
