import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

import 'html_pipeline_registry.dart';
import 'html_transform_text_html_test.mocks.dart';

void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  const probe = '<style>.x{color:red;position:fixed}</style>'
      '<p class="x" onclick="alert(1)">x</p>';

  HtmlPipelineWiring observedWiring(String html) {
    final style = RegExp(r'<style[^>]*>(.*?)</style>', dotAll: true)
        .firstMatch(html)
        ?.group(1);
    if (style == null) return HtmlPipelineWiring.stripsStyles;
    final sanitized = !style.contains('position') && !html.contains('onclick');
    return sanitized
        ? HtmlPipelineWiring.sanitizes
        : HtmlPipelineWiring.passesThrough;
  }

  test('covers every TransformConfiguration factory', () {
    final fromSource = htmlPipelineFactoryNamesFromSource(
      htmlPipelineTransformConfigurationSource(),
    );
    final fromRegistry =
        htmlPipelineRegistry().map((row) => row.factoryName).toSet();

    expect(
      fromRegistry,
      fromSource,
      reason: 'a new pipeline needs a row in htmlPipelineRegistry()',
    );
  });

  // A text/plain pipeline escapes the probe instead of parsing it; its
  // sanitizing is covered by html_transform_text_plain_test.dart.
  for (final row in htmlPipelineRegistry().where((row) => row.takesHtml)) {
    test('${row.name} ${row.wiring.name}', () async {
      final html = await htmlTransform.transformToHtml(
        htmlContent: probe,
        transformConfiguration: row.build(),
      );

      expect(observedWiring(html), row.wiring, reason: 'output: $html');
    });
  }
}
