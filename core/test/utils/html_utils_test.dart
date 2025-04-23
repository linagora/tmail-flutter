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
}