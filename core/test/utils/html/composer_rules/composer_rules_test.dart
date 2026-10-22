import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' show parse;

import '../../../fixtures/html_emails/html_email_corpus.g.dart';
import '../../html_pipeline_registry.dart';
import 'composer_rules.dart';
import 'known_composer_failures.dart';

/// Fixtures have no cid map, so the pipelines never download.
class _OfflineDioClient extends Fake implements DioClient {}

final _driveCard = FileLinkCardHtmlBuilder.buildFileLinkCard(
  const FileLinkCardContent(
    href: 'https://fixture.invalid/link/drive',
    title: 'report.pdf',
    actionLabel: 'Open',
    iconZoneHtml: '<div>PDF</div>',
  ),
);

Future<String> _transform(HtmlPipelineRow row, String html) =>
    HtmlTransform(_OfflineDioClient(), const HtmlEscape()).transformToHtml(
      htmlContent: html,
      transformConfiguration: row.build(),
    );

void _composerTest(String name, Future<void> Function() body) =>
    test(name, body, skip: knownComposerFailures[name]);

/// What the composer pipelines must keep or must not add: the content of
/// every fixture, a stable second pass, no display-only markup, uneditable
/// drive cards, and a composer signature that changes only `line-height`.
void main() {
  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  final rows = htmlPipelineRegistry().where((row) => row.rules.composer);
  final fixtures = htmlEmailCorpus.where((fixture) => !fixture.isPlainText);

  for (final row in rows) {
    group(row.name, () {
      for (final fixture in fixtures) {
        final id = '${fixture.category}/${fixture.name}';

        _composerTest('${row.name} $id preserves content', () async {
          final out = await _transform(row, fixture.html);
          expect(preservationFailures(fixture, out), isEmpty);
        });

        _composerTest('${row.name} $id is idempotent', () async {
          final once = await _transform(row, fixture.html);
          final twice = await _transform(row, once);
          expect(idempotenceFailures(parse(once), parse(twice)), isEmpty);
        });

        _composerTest('${row.name} $id adds no display-only markup', () async {
          final out = await _transform(row, fixture.html);
          expect(displayOnlyLeaks(parse(fixture.html), parse(out)), isEmpty);
        });

        if (row.factoryName == 'forComposerSignature') {
          _composerTest('${row.name} $id changes only line-height', () async {
            final out = await _transform(row, fixture.html);
            expect(lineHeightOnlyFailures(parse(fixture.html), parse(out)), isEmpty);
          });
        }
      }

      _composerTest('${row.name} keeps drive cards uneditable', () async {
        final out = await _transform(row, '<p>See</p>$_driveCard');
        expect(driveCardFailures(parse(out)), isEmpty);
      });
    });
  }
}
