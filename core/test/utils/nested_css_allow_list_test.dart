import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

import 'html_transform_text_html_test.mocks.dart';

/// Rules nested in `@media` go through the same property allow-list as
/// flat CSS, and other at-rules are dropped.
void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  final pipelines = <String, TransformConfiguration Function()>{
    'web viewer': TransformConfiguration.forPreviewEmailOnWeb,
    'mobile viewer': TransformConfiguration.forPreviewEmail,
    'standard': () => TransformConfiguration.standardConfiguration,
  };

  pipelines.forEach((name, create) {
    group('$name sanitizes nested CSS', () {
      test('drops disallowed properties inside @media', () async {
        final out = await htmlTransform.transformToHtml(
          htmlContent: '<style>@media all{body{position:fixed;z-index:9999;color:red}}</style><p>x</p>',
          transformConfiguration: create(),
        );

        expect(out, contains('@media'));
        expect(out, isNot(contains('position')));
        expect(out, isNot(contains('z-index')));
      });

      test('drops @supports blocks', () async {
        final out = await htmlTransform.transformToHtml(
          htmlContent: '<style>.a{color:red} @supports (display:grid){.a{position:fixed}}</style><p class="a">x</p>',
          transformConfiguration: create(),
        );

        expect(out, isNot(contains('@supports')));
        expect(out, isNot(contains('position')));
      });
    });
  });
}
