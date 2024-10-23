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
  });
}
