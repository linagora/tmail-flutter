import 'package:core/presentation/utils/html_transformer/dom/image_transformers.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const imageTransformer = ImageTransformer();

  group('findImageUrlFromStyleTag test', () {
    test('Test findImageUrlFromStyleTag with valid input', () {
      const style = 'background-image: url(\'example.com/image.jpg\');';
      final result = imageTransformer.findImageUrlFromStyleTag(style);
      expect(result!.value1, 'background-image: url(\'example.com/image.jpg\')');
      expect(result.value2, 'example.com/image.jpg');
    });

    test('Test findImageUrlFromStyleTag with valid input and no quotation marks', () {
      const style = 'background-image: url(example.com/image.jpg);';
      final result = imageTransformer.findImageUrlFromStyleTag(style);
      expect(result!.value1, 'background-image: url(example.com/image.jpg)');
      expect(result.value2, 'example.com/image.jpg');
    });

    test('Test findImageUrlFromStyleTag with empty input', () {
      const style = '';
      final result = imageTransformer.findImageUrlFromStyleTag(style);
      expect(result, null);
    });

    test('Test findImageUrlFromStyleTag with invalid input', () {
      const style = 'background-image: invalid-url(\'example.com/image.jpg\');';
      final result = imageTransformer.findImageUrlFromStyleTag(style);
      expect(result, null);
    });
  });

  group('HtmlUtils.unescapeHtml', () {
    test('should return original string when no HTML entities present', () {
      const input = 'This is a normal string';
      expect(HtmlUtils.unescapeHtml(input), equals(input));
    });

    test('should unescape basic HTML entities', () {
      const input = '&lt;div&gt;Hello &amp; Welcome&lt;/div&gt;';
      const expected = '<div>Hello & Welcome</div>';
      expect(HtmlUtils.unescapeHtml(input), equals(expected));
    });

    test('should unescape numeric decimal HTML entities', () {
      const input = '&#65;&#66;&#67;';
      const expected = 'ABC';
      expect(HtmlUtils.unescapeHtml(input), equals(expected));
    });

    test('should unescape numeric hexadecimal HTML entities', () {
      const input = '&#x41;&#x42;&#x43;';
      const expected = 'ABC';
      expect(HtmlUtils.unescapeHtml(input), equals(expected));
    });

    test('should unescape special character entities', () {
      const input = '&quot;Hello&apos; &copy; &reg; &trade;';
      const expected = '"Hello\' © ® ™';
      expect(HtmlUtils.unescapeHtml(input), equals(expected));
    });

    test('should handle empty string', () {
      const input = '';
      expect(HtmlUtils.unescapeHtml(input), isEmpty);
    });

    test('should handle string with only HTML entity', () {
      const input = '&amp;';
      const expected = '&';
      expect(HtmlUtils.unescapeHtml(input), equals(expected));
    });

    test('should leave invalid HTML entities unchanged', () {
      const input = 'This & is not an entity &invalid; &123';
      const expected = 'This & is not an entity &invalid; &123';
      expect(HtmlUtils.unescapeHtml(input), equals(expected));
    });

    test('should handle Unicode characters', () {
      const input = '&lt;こんにちは&gt;'; // <こんにちは>
      const expected = '<こんにちは>';
      expect(HtmlUtils.unescapeHtml(input), equals(expected));
    });

    test('should handle complex mixed entities', () {
      const input = '&lt;script&gt;alert(&quot;Hello&quot;);&lt;/script&gt;&amp;&#64;&#x40;';
      const expected = '<script>alert("Hello");</script>&@@';
      expect(HtmlUtils.unescapeHtml(input), equals(expected));
    });
  });

  group('HtmlUtils.removeWhitespace', () {
    test('should remove carriage returns (\\r)', () {
      expect(HtmlUtils.removeWhitespace('Hello\rWorld'), equals('HelloWorld'));
      expect(HtmlUtils.removeWhitespace('\r\r\r'), equals(''));
      expect(HtmlUtils.removeWhitespace('a\rb\rc'), equals('abc'));
    });

    test('should remove newlines (\\n)', () {
      expect(HtmlUtils.removeWhitespace('Hello\nWorld'), equals('HelloWorld'));
      expect(HtmlUtils.removeWhitespace('\n\n\n'), equals(''));
      expect(HtmlUtils.removeWhitespace('a\nb\nc'), equals('abc'));
    });

    test('should remove tabs (\\t)', () {
      expect(HtmlUtils.removeWhitespace('Hello\tWorld'), equals('HelloWorld'));
      expect(HtmlUtils.removeWhitespace('\t\t\t'), equals(''));
      expect(HtmlUtils.removeWhitespace('a\tb\tc'), equals('abc'));
    });

    test('should remove all whitespace characters when combined', () {
      expect(HtmlUtils.removeWhitespace('Hello\r\n\tWorld'), equals('HelloWorld'));
      expect(HtmlUtils.removeWhitespace('a\rb\nc\td'), equals('abcd'));
      expect(HtmlUtils.removeWhitespace('\r\n\t\r\n\t'), equals(''));
    });

    test('should return empty string for empty input', () {
      expect(HtmlUtils.removeWhitespace(''), equals(''));
    });

    test('should leave string unchanged when no whitespace present', () {
      expect(HtmlUtils.removeWhitespace('HelloWorld'), equals('HelloWorld'));
      expect(HtmlUtils.removeWhitespace('12345'), equals('12345'));
      expect(HtmlUtils.removeWhitespace('!@#\$%^'), equals('!@#\$%^'));
    });

    test('should preserve spaces if not configured to remove them', () {
      expect(HtmlUtils.removeWhitespace('Hello World'), equals('Hello World'));
      expect(HtmlUtils.removeWhitespace('a b c'), equals('a b c'));
    });

    test('should handle mixed content with various whitespace', () {
      expect(
        HtmlUtils.removeWhitespace('Text\rwith\nnew\tlines\r\nand\ttabs'),
        equals('Textwithnewlinesandtabs'),
      );
    });
  });

  group('HtmlUtils.extractPlainText', () {
    test('removes blockquote and keeps other text', () {
      const html = '''
        <div>Hello <b>world</b></div>
        <blockquote>
          <p>should be removed</p>
        </blockquote>
        <div>Final</div>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'Hello world Final');
    });

    test('removes nested blockquotes', () {
      const html = '''
        <p>Keep this</p>
        <blockquote>
          <p>remove me</p>
          <blockquote><p>nested remove</p></blockquote>
        </blockquote>
        <span>After</span>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'Keep this After');
    });

    test('removes multiple blockquotes at same level', () {
      const html = '''
        <p>Start</p>
        <blockquote><p>first</p></blockquote>
        <blockquote><p>second</p></blockquote>
        <p>End</p>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'Start End');
    });

    test('removes all html tags outside blockquotes', () {
      const html = '<div>Hello <b>bold</b> <i>italic</i></div>';
      expect(HtmlUtils.extractPlainText(html), 'Hello bold italic');
    });

    test('normalizes whitespaces', () {
      const html = '''
        <p>Hello</p>     
        <blockquote><p>remove</p></blockquote>
        <p>   World   </p>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'Hello World');
    });

    test('returns empty string if only blockquote present', () {
      const html = '<blockquote><p>everything removed</p></blockquote>';
      expect(HtmlUtils.extractPlainText(html), '');
    });

    test('case insensitive blockquote tag', () {
      const html = '''
        <BLOCKQUOTE><p>Remove me</p></BLOCKQUOTE>
        <p>Keep me</p>
      ''';
      expect(HtmlUtils.extractPlainText(html), 'Keep me');
    });

    test('handles text without any html', () {
      const html = 'Just plain text already';
      expect(HtmlUtils.extractPlainText(html), 'Just plain text already');
    });

    test('decodes HTML entities correctly', () {
      const html = '''
        <p>A &amp; B</p>
        <p>5 &lt; 10 &gt; 3</p>
        <p>Hello&nbsp;World</p>
        <blockquote><p>remove &copy;</p></blockquote>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'A & B 5 < 10 > 3 Hello World');
    });

    test('handles double-encoded html entities with full decode', () {
      const html = '''
        <p>Before</p>
        &amp;lt;div&amp;gt;Hello&amp;lt;/div&amp;gt;
        <p>After</p>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'Before Hello After');
    });


    test('handles emoji correctly', () {
      const html = '''
        <p>Hello 🌍🚀</p>
        <blockquote><p>😅 should be removed</p></blockquote>
        <p>Done ✅</p>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'Hello 🌍🚀 Done ✅');
    });

    test('handles Cyrillic text', () {
      const html = '''
        <p>Привет мир</p>
        <blockquote><p>Удалить это</p></blockquote>
        <p>Отчёт завершён</p>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'Привет мир Отчёт завершён');
    });

    test('handles Japanese text', () {
      const html = '''
        <p>こんにちは 世界</p>
        <blockquote><p>これは削除される</p></blockquote>
        <p>完了しました</p>
      ''';

      expect(HtmlUtils.extractPlainText(html), 'こんにちは 世界 完了しました');
    });

    test('handles Chinese text', () {
      const html = '''
        <p>你好，世界</p>
        <blockquote><p>这部分要删除</p></blockquote>
        <p>完成</p>
      ''';

      expect(HtmlUtils.extractPlainText(html), '你好，世界 完成');
    });

    test('returns empty string when input is empty', () {
      expect(HtmlUtils.extractPlainText(''), '');
    });

    test('handles html without closing tags', () {
      const html = '<p>Hello <b>World';
      expect(HtmlUtils.extractPlainText(html), 'Hello World');
    });

    test('ignores numeric-like tags (e.g. <123>) as text', () {
      const html = '<p>value is <123> not a tag</p>';
      // <123> is not a valid HTML tag, so it should be kept
      expect(HtmlUtils.extractPlainText(html), 'value is <123> not a tag');
    });

    test('keeps unknown HTML entities as-is', () {
      const html = '<p>custom &unknown; entity</p>';
      // if the entity cannot be decoded, keep it as is
      expect(HtmlUtils.extractPlainText(html), 'custom &unknown; entity');
    });

    test('removes nested blockquote completely', () {
      const html = '''
        <p>Intro</p>
        <blockquote>
          <p>nested <blockquote>deep</blockquote></p>
        </blockquote>
        <p>Outro</p>
      ''';
      expect(HtmlUtils.extractPlainText(html), 'Intro Outro');
    });

    test('preserves spacing when multiple tags removed', () {
      const html = '<div>Hello</div><span>World</span>';
      expect(HtmlUtils.extractPlainText(html), 'Hello World');
    });

    test('decodes multiple levels of entities', () {
      // &amp;lt; = &lt; → <
      const html = '<p>&amp;lt;b&amp;gt;Bold&amp;lt;/b&amp;gt;</p>';
      // Because <b> is decoded into a real tag and removed, only Bold remains
      expect(HtmlUtils.extractPlainText(html), 'Bold');
    });

    test('keeps unknown tags as plain text', () {
      const html = '<heloloasdadadadadsad>dab';
      expect(HtmlUtils.extractPlainText(html), '<heloloasdadadadadsad>dab');
    });
  });
}