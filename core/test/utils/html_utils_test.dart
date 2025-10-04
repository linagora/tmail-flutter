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

  group('HtmlUtils.wrapPlainTextLinks', () {
    test('wraps plain text link inside <p>', () {
      const input = '<div><p>https://google.com</p></div>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<div><p><a href="https://google.com">https://google.com</a></p></div>',
      );
    });

    test('keeps existing <a> tags unchanged', () {
      const input = "<div><a href='https://google.com'>Hello</a></div>";
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        "<div><a href=\"https://google.com\">Hello</a></div>",
      );
    });

    test('wraps multiple links in text', () {
      const input = '<p>Go to https://flutter.dev and https://dart.dev now</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Go to <a href="https://flutter.dev">https://flutter.dev</a> and <a href="https://dart.dev">https://dart.dev</a> now</p>',
      );
    });

    test('keeps non-link text unchanged', () {
      const input = '<p>Hello world!</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(result.trim(), '<p>Hello world!</p>');
    });

    test('handles mixed content with existing and new links', () {
      const input = '''
<div>
<p>Visit https://google.com or <a href="https://flutter.dev">Flutter</a></p>
</div>
''';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<div>\n<p>Visit <a href="https://google.com">https://google.com</a> or <a href="https://flutter.dev">Flutter</a></p>\n</div>',
      );
    });

    test('returns input if body is null', () {
      const input = '';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(result, input);
    });

    test('handles link with trailing punctuation', () {
      const input = '<p>Check https://google.com, it is great!</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Check <a href="https://google.com">https://google.com</a>, it is great!</p>',
      );
    });

    test('handles link with query parameters', () {
      const input = '<p>Go to https://example.com/search?q=test</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Go to <a href="https://example.com/search?q=test">https://example.com/search?q=test</a></p>',
      );
    });

    test('wraps link inside span', () {
      const input = '<span>See https://flutter.dev/docs for details</span>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<span>See <a href="https://flutter.dev/docs">https://flutter.dev/docs</a> for details</span>',
      );
    });

    test('handles multiple paragraphs with links', () {
      const input = '''
<div>
  <p>Visit https://google.com</p>
  <p>Then go to https://flutter.dev</p>
</div>
''';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<div>\n  <p>Visit <a href="https://google.com">https://google.com</a></p>\n  <p>Then go to <a href="https://flutter.dev">https://flutter.dev</a></p>\n</div>',
      );
    });

    test('ignores links already wrapped in <a>', () {
      const input =
          '<p><a href="https://google.com">https://google.com</a> is wrapped</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p><a href="https://google.com">https://google.com</a> is wrapped</p>',
      );
    });

    test('handles link with trailing parenthesis correctly', () {
      const input = '<p>(https://example.com)</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>(<a href="https://example.com">https://example.com</a>)</p>',
      );
    });

    test('handles link followed by exclamation mark', () {
      const input = '<p>Wow https://amazing.dev!</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Wow <a href="https://amazing.dev">https://amazing.dev</a>!</p>',
      );
    });

    test('handles link followed by question mark', () {
      const input = '<p>What is https://example.com?</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>What is <a href="https://example.com">https://example.com</a>?</p>',
      );
    });

    test('handles http (non-https) link', () {
      const input = '<p>Visit http://example.org for info</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Visit <a href="http://example.org">http://example.org</a> for info</p>',
      );
    });

    test('handles multiple text segments and links mixed', () {
      const input =
          '<p>Before https://link1.com middle https://link2.com end</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Before <a href="https://link1.com">https://link1.com</a> middle <a href="https://link2.com">https://link2.com</a> end</p>',
      );
    });

    test('handles sentence with link between words', () {
      const input = '<p>Check this https://docs.flutter.dev today</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Check this <a href="https://docs.flutter.dev">https://docs.flutter.dev</a> today</p>',
      );
    });

    test('handles link at beginning of text', () {
      const input = '<p>https://start.com is the first link</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p><a href="https://start.com">https://start.com</a> is the first link</p>',
      );
    });

    test('handles link at end of text', () {
      const input = '<p>Go to end https://end.com</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Go to end <a href="https://end.com">https://end.com</a></p>',
      );
    });

    test('handles text containing only the link', () {
      const input = '<p>https://onlylink.com</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p><a href="https://onlylink.com">https://onlylink.com</a></p>',
      );
    });

    test('wraps link starting with www', () {
      const input = '<p>Visit www.google.com for info</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Visit <a href="https://www.google.com">www.google.com</a> for info</p>',
      );
    });

    test('handles link followed by colon', () {
      const input = '<p>URL: https://flutter.dev:</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>URL: <a href="https://flutter.dev">https://flutter.dev</a>:</p>',
      );
    });

    test('handles parentheses around link', () {
      const input = '<p>(https://parenthesis.com)</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>(<a href="https://parenthesis.com">https://parenthesis.com</a>)</p>',
      );
    });

    test('handles link inside nested span', () {
      const input = '<p><span>Check https://nested.com inside span</span></p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p><span>Check <a href="https://nested.com">https://nested.com</a> inside span</span></p>',
      );
    });

    test('handles multiple links across multiple tags', () {
      const input = '<p>First https://one.com</p><p>Second https://two.com</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>First <a href="https://one.com">https://one.com</a></p><p>Second <a href="https://two.com">https://two.com</a></p>',
      );
    });

    test('handles link with port number', () {
      const input = '<p>Visit http://localhost:8080/home</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Visit <a href="http://localhost:8080/home">http://localhost:8080/home</a></p>',
      );
    });

    test('handles unicode domain', () {
      const input = '<p>Try https://例子.测试</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Try <a href="https://例子.测试">https://例子.测试</a></p>',
      );
    });

    test('handles link with query params & escapes correctly', () {
      const input = '<p>Search https://google.com?q=flutter&lang=en</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<p>Search <a href="https://google.com?q=flutter&amp;lang=en">https://google.com?q=flutter&amp;lang=en</a></p>',
      );
    });

    test('does not wrap text inside existing <a>', () {
      const input = '<a href="https://flutter.dev">https://flutter.dev</a>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(
        result.trim(),
        '<a href="https://flutter.dev">https://flutter.dev</a>',
      );
    });

    test('handles empty html safely', () {
      const input = '';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(result, '');
    });

    test('handles text without link', () {
      const input = '<p>No link here</p>';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(result.trim(), '<p>No link here</p>');
    });

    test('handles invalid HTML gracefully', () {
      const input = '<p>Some broken <div> www.test.com';
      final result = HtmlUtils.wrapPlainTextLinks(input);
      expect(result.contains('<a href="https://www.test.com">'), true);
    });

    test('ignores URLs inside img/video/link/script attributes', () {
      const input = '''
<div>
  <p>Visit www.google.com</p>
  <img src="https://example.com/image.jpg" alt="example">
  <video src="https://example.com/video.mp4"></video>
  <a href="https://flutter.dev">Flutter</a>
</div>
''';

      final result = HtmlUtils.wrapPlainTextLinks(input);

      expect(
        result.contains('<a href="https://www.google.com">www.google.com</a>'),
        true,
        reason: 'Text link www.google.com should be wrapped',
      );

      expect(result.contains('<img src="https://example.com/image.jpg"'), true);
      expect(result.contains('<video src="https://example.com/video.mp4"'), true);
      expect(result.contains('<a href="https://flutter.dev">Flutter</a>'), true);
    });

    test('does not alter src or href attributes', () {
      const input = '''
<div>
  <p>Visit www.google.com</p>
  <img src="https://example.com/image.jpg" alt="example">
  <video src="https://example.com/video.mp4"></video>
  <a href="https://flutter.dev">Flutter</a>
</div>
''';

      final result = HtmlUtils.wrapPlainTextLinks(input).trim();

      expect(
        result,
        '<div>\n  <p>Visit <a href="https://www.google.com">www.google.com</a></p>\n  '
            '<img src="https://example.com/image.jpg" alt="example">\n  '
            '<video src="https://example.com/video.mp4"></video>\n  '
            '<a href="https://flutter.dev">Flutter</a>\n</div>',
      );
    });

    test('does NOT wrap URLs inside special tags (img, video, script, link, iframe)', () {
      const input = '''
<div>
  <p>Check www.google.com</p>
  <img src="https://cdn.example.com/image.jpg" alt="Sample image with link google.com">
  <video src="https://cdn.example.com/video.mp4">
    www.google.com
  </video>
  <script>console.log("Visit www.google.com");</script>
  <iframe src="https://player.example.com"></iframe>
  <link rel="stylesheet" href="https://cdn.example.com/style.css">
</div>
''';

      final result = HtmlUtils.wrapPlainTextLinks(input);
      // The URL in <p> should be wrapped
      expect(
        result.contains('<a href="https://www.google.com">www.google.com</a>'),
        true,
        reason:
            'The text www.google.com inside <p> should be wrapped into a link',
      );

      // There must NOT be any <a> tag inside these special tags
      final forbiddenTags = ['img', 'video', 'script', 'iframe', 'link'];
      for (final tag in forbiddenTags) {
        final pattern = RegExp('<$tag[^>]*>.*?<\\/\\s*$tag>', dotAll: true);
        final matches = pattern.allMatches(result);
        for (final match in matches) {
          final segment = match.group(0)!;
          expect(
            segment.contains('<a '),
            false,
            reason: 'There must be no <a> tag inside <$tag>',
          );
        }
      }

      // There must NOT be any <a> tag inside href/src attributes
      final attributePattern = RegExp(r'(src|href)="[^"]*<a[^"]*"');
      expect(
        attributePattern.hasMatch(result),
        false,
        reason: 'There must be no <a> tag inside href or src attributes',
      );
    });
  });
}