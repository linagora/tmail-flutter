import 'dart:convert';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures have no cid map, so the pipelines never download.
class _OfflineDioClient extends Fake implements DioClient {}

void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(_OfflineDioClient(), const HtmlEscape());
  });

  group('forPrintEmail (already sanitized display content)', () {
    test('SHOULD restore lazy background images', () async {
      final out = await htmlTransform.transformToHtml(
        htmlContent: '<div style="color: red" data-src="https://example.com/bg.png" lazy="">News</div>',
        transformConfiguration: TransformConfiguration.forPrintEmail(),
      );

      expect(out, contains('background-image:url(https://example.com/bg.png)'));
    });

    test('SHOULD still remove script elements', () async {
      final out = await htmlTransform.transformToHtml(
        htmlContent: '<div>Body</div><script>alert(1)</script>',
        transformConfiguration: TransformConfiguration.forPrintEmail(),
      );

      expect(out, contains('Body'));
      expect(out.toLowerCase(), isNot(contains('<script')));
    });
  });
}
