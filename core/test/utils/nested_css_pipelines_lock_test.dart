import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/newsletter_stylesheets.dart';
import 'html_pipeline_registry.dart';
import 'html_transform_text_html_test.mocks.dart';

/// Every HTML pipeline shares one sanitizer, so a change to how it treats
/// `<style>` reaches all of them. These tests run each pipeline on real
/// newsletter stylesheets and on plain CSS to lock what must not change.
void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  final sanitizingPipelines = sanitizingPipelineFactories();
  final passThroughPipelines = passThroughPipelineFactories();
  final allPipelines = {...sanitizingPipelines, ...passThroughPipelines};

  const savedPipelines = [
    'forDraftsEmail',
    'forEditDraftsEmail',
    'forRestoreEmail',
    'forSignatureIdentity',
  ];

  String normalize(String css) => css
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'\s+'), '')
      .toLowerCase();

  String stylesOf(String html) => normalize(
        RegExp(r'<style[^>]*>(.*?)</style>', dotAll: true)
            .allMatches(html)
            .map((m) => m.group(1)!)
            .join(' '),
      );

  // Bodies of the `@media` blocks whose normalized prelude is [prelude].
  List<String> mediaBodies(String css, String prelude) {
    final bodies = <String>[];
    var from = 0;
    while (true) {
      final start = css.indexOf('$prelude{', from);
      if (start == -1) return bodies;
      final open = start + prelude.length;
      var depth = 0;
      var end = open;
      for (; end < css.length; end++) {
        if (css[end] == '{') depth++;
        if (css[end] == '}' && --depth == 0) break;
      }
      bodies.add(css.substring(open + 1, end));
      from = end;
    }
  }

  Future<String> run(TransformConfiguration Function() create, String html) =>
      htmlTransform.transformToHtml(htmlContent: html, transformConfiguration: create());

  group('newsletter @media rules survive every pipeline', () {
    for (final sheet in newsletterStylesheets) {
      allPipelines.forEach((pipeline, create) {
        test('${sheet.name} through $pipeline', () async {
          final out = stylesOf(await run(create, sheet.html));

          expect(
            '@media'.allMatches(out).length,
            '@media'.allMatches(stylesOf(sheet.html)).length,
            reason: 'every @media block is kept',
          );
          sheet.keptInMedia.forEach((prelude, declarations) {
            final body = mediaBodies(out, prelude).join(';');
            for (final declaration in declarations) {
              expect(body, contains(declaration), reason: '$prelude keeps $declaration');
            }
          });
          final outsideMedia = sheet.keptInMedia.keys.fold(
            out,
            (css, prelude) => mediaBodies(css, prelude)
                .fold(css, (rest, body) => rest.replaceFirst('$prelude{$body}', '')),
          );
          for (final declaration in sheet.keptOutsideMedia) {
            expect(outsideMedia, contains(declaration), reason: 'plain rules keep $declaration');
          }
        });
      });
    }
  });

  group('saved content is stable when sanitized again', () {
    for (final sheet in newsletterStylesheets) {
      for (final pipeline in savedPipelines) {
        test('${sheet.name} through $pipeline twice', () async {
          final create = sanitizingPipelines[pipeline]!;
          final once = await run(create, sheet.html);
          final twice = await run(create, once);

          expect(stylesOf(twice), stylesOf(once));
        });
      }
    }
  });

  group('plain stylesheets and inline styles are unaffected by nested CSS handling', () {
    const html = '<style>.a{color:red;padding:4px;position:fixed}</style>'
        '<p class="a" style="color:blue;margin:0;position:absolute">x</p>';

    sanitizingPipelines.forEach((pipeline, create) {
      test('$pipeline keeps allowed and drops disallowed flat properties', () async {
        final out = await run(create, html);
        final css = stylesOf(out);
        final inline = normalize(RegExp(r'<p[^>]*style="([^"]*)"').firstMatch(out)!.group(1)!);

        expect(css, allOf(contains('color:red'), contains('padding:4px')));
        expect(css, isNot(contains('position')));
        expect(inline, allOf(contains('color:blue'), contains('margin:0')));
        expect(inline, isNot(contains('position')));
      });
    });

    passThroughPipelines.forEach((pipeline, create) {
      test('$pipeline leaves the stylesheet as is', () async {
        expect(stylesOf(await run(create, html)), stylesOf(html));
      });
    });
  });

  group('overlay declarations inside @media are dropped by every sanitizing pipeline', () {
    const html = '<style>@media all{.x{position:fixed;z-index:9999;top:0;left:0}.y{color:red}}</style>'
        '<div class="x y">x</div>';

    sanitizingPipelines.forEach((pipeline, create) {
      test(pipeline, () async {
        final css = stylesOf(await run(create, html));

        expect(css, isNot(contains('position')));
        expect(css, isNot(contains('z-index')));
      });
    });
  });
}
