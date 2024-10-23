import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('StandardizeHtmlSanitizingTransformers::test', () {
    const transformer = StandardizeHtmlSanitizingTransformers();
    const htmlEscape = HtmlEscape();

    test('SHOULD remove attributes of IMG tag WHEN they are invalid', () {
      const inputHtml = '<img src="1" href="1" onerror="javascript:alert(1)">';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<img src="1">'));
    });

    test('SHOULD remove all SCRIPTS tags', () {
      const inputHtml = '''
        </script><img/*%00/src="worksinchrome&colon;prompt&#x28;1&#x29;"/%00*/onerror='eval(src)'>
      ''';
      final result = transformer.process(inputHtml, htmlEscape).trim();

      expect(result, equals('<img>'));
    });

    test('SHOULD remove all IFRAME tags', () {
      const inputHtml = '<iframe style="xg-p:absolute;top:0;left:0;width:100%;height:100%" onmouseover="prompt(1)">';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals(''));
    });

    test('SHOULD remove href attribute of A tag WHEN it is invalid', () {
      const inputHtml = '<a href="javas\x06cript:javascript:alert(1)" id="fuzzelement1">test</a>';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<a>test</a>'));
    });

    test('SHOULD persist value src attribute of IMG tag WHEN it is base64 string', () {
      const inputHtml = '<img src="data:image/jpeg;base64,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">';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<img src="data:image/jpeg;base64,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">'));
    });

    test('SHOULD persist value src attribute of IMG tag WHEN it is CID string', () {
      const inputHtml = '<img src="cid:email123">';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<img src="cid:email123">'));
    });
  });
}
