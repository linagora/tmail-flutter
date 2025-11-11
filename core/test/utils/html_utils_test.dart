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
      // Unknown HTML tags should be keep as html text,
      // not stripped or removed by the extractor.
      const html = '<heloloasdadadadadsad>dab';
      expect(
        HtmlUtils.extractPlainText(html),
        '<heloloasdadadadadsad>dab</heloloasdadadadadsad>',
      );
    });

    test('removes deeply nested blockquotes with mixed content', () {
      const html = '''
      <p>Intro</p>
      <blockquote>
        <div>Level1</div>
        <blockquote>
          <p>Level2</p>
          <blockquote>
            <span>Level3</span>
            <blockquote>
              <i>Level4</i>
            </blockquote>
          </blockquote>
        </blockquote>
      </blockquote>
      <p>Outro</p>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Intro Outro');
    });

    test('removes adjacent blockquotes and preserves surrounding text', () {
      const html = '''
      <div>Top</div>
      <blockquote><p>Q1</p></blockquote>
      <blockquote><p>Q2</p></blockquote>
      <blockquote><p>Q3</p></blockquote>
      <div>Bottom</div>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Top Bottom');
    });

    test('removes blockquote with attributes and cite', () {
      const html = '''
      <p>Start</p>
      <blockquote type="cite" style="border-left:2px solid #eee;">
        <cite>On Nov 10 ...</cite>
        <div>Quoted text</div>
      </blockquote>
      <p>End</p>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Start End');
    });

    test('keeps content when removeQuotes=false', () {
      const html = '''
      <p>A</p>
      <blockquote><p>B inside quote</p></blockquote>
      <p>C</p>
    ''';
      expect(
        HtmlUtils.extractPlainText(html, removeQuotes: false),
        'A B inside quote C',
      );
    });

    test('keeps content of encoded blockquotes since they are not real tags', () {
      const html = '''
      <p>Before</p>
      &amp;lt;blockquote&amp;gt;Inner from encoded quote&amp;lt;/blockquote&amp;gt;
      <p>After</p>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Before Inner from encoded quote After');
    });

    test('handles multiple encoded tags that become real tags then stripped', () {
      const html = '''
      &amp;lt;div&amp;gt;A&amp;lt;/div&amp;gt;&amp;lt;span&amp;gt;B&amp;lt;/span&amp;gt;
    ''';
      // After decoding twice: <div>A</div><span>B</span> → "A B"
      expect(HtmlUtils.extractPlainText(html), 'A B');
    });

    test('removes style and script tags when enabled', () {
      const html = '''
      <p>Keep</p>
      <style>.x{color:red} body{margin:0}</style>
      <script>console.log('hi')</script>
      <p>Me</p>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Keep Me');
    });

    test('keeps style content when removeStyle=false', () {
      const html = '''
      <p>Top</p>
      <style>.x { color: red } /* CSS */</style>
      <p>Bottom</p>
    ''';
      // When removeStyle=false, style content remains after tag stripping.
      expect(
        HtmlUtils.extractPlainText(html, removeStyle: false),
        'Top <style>.x { color: red } /* CSS */</style> Bottom',
      );
    });

    test('keeps script content when removeScript=false', () {
      const html = '''
      <p>Hello</p>
      <script>var x = 1 < 2 && 3 > 2; alert(x);</script>
      <p>World</p>
    ''';
      expect(
        HtmlUtils.extractPlainText(html, removeScript: false),
        'Hello <script>var x = 1 < 2 && 3 > 2; alert(x);</script> World',
      );
    });

    test('collapses multiple <br> tags into a single space', () {
      const html = '''
      Hello<br><br/><br   />World
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Hello World');
    });

    test('handles mixed languages inside and outside quotes', () {
      const html = '''
      <p>Xin chào</p>
      <blockquote><p>Bonjour (quoted)</p></blockquote>
      <p>こんにちは</p>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Xin chào こんにちは');
    });

    test('handles messy whitespace around quotes and tags', () {
      const html = '''
      <div> A  </div>
      <blockquote>
         <p>   should be gone   </p>
      </blockquote>
      <span>   B   </span>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'A B');
    });

    test('ignores disclaimers when wrapped inside blockquotes', () {
      const html = '''
      <p>Keep</p>
      <blockquote>
        <div style="margin:5px; font-size:11px; color:#104c88;">
          Ce message et les éventuels documents joints...
        </div>
      </blockquote>
      <p>Text</p>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Keep Text');
    });

    test('keeps disclaimers that are not wrapped in blockquotes', () {
      const html = '''
      <p>Top</p>
      <div style="font-size:11px">Ce message et les éventuels documents joints...</div>
      <p>Bottom</p>
    ''';
      expect(HtmlUtils.extractPlainText(html),
          'Top Ce message et les éventuels documents joints... Bottom');
    });

    test('removes malformed nested blockquotes completely', () {
      const html = '''
      <p>Intro</p>
      <blockquote>
        <div>Q1
          <blockquote>Q2
            <blockquote>Q3</blockquote
          ></blockquote>
        </div>
      </blockquote>
      <p>Outro</p>
    ''';
      expect(HtmlUtils.extractPlainText(html), 'Intro Outro');
    });

    test('leaves unknown entities untouched while decoding known ones', () {
      const html = '''
      <p>&copy; 2025 &unknown; &amp; &lt;tag&gt;</p>
    ''';
      // &copy; → ©, &amp; → &, &lt;tag&gt; → <tag>, unknown entities stay as-is
      expect(HtmlUtils.extractPlainText(html), '© 2025 &unknown; & <tag>');
    });

    test('keeps unknown tags as html text even when adjacent', () {
      const html = '<abc>a</abc><xyz>b</xyz>';
      expect(HtmlUtils.extractPlainText(html), '<abc>a</abc><xyz>b</xyz>');
    });

    test('handles encoded unknown tags that become html text after decoding', () {
      const html = '&amp;lt;weird&amp;gt;X&amp;lt;/weird&amp;gt;Y';
      expect(HtmlUtils.extractPlainText(html), '<weird>X</weird>Y');
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

    test('Protocol variations: http/https/www', () {
      const html = 'A https://example.com B http://foo.bar C www.site.com';
      final result = HtmlUtils.wrapPlainTextLinks(html);

      expect(result, contains('<a href="https://example.com">https://example.com</a>'));
      expect(result, contains('<a href="http://foo.bar">http://foo.bar</a>'));
      expect(result, contains('<a href="https://www.site.com">www.site.com</a>'));
    });

    test('Protocol variations: ftp, mailto, file', () {
      const html =
          'ftp://files.example.com mailto:me@example.com file:///Users/me/readme.txt';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(
        out,
        contains('<a href="ftp://files.example.com">ftp://files.example.com</a>'),
      );

      expect(
        out,
        contains('<a href="mailto:me@example.com">mailto:me@example.com</a>'),
      );

      expect(
        out,
        contains(
          '<a href="file:///Users/me/readme.txt">file:///Users/me/readme.txt</a>',
        ),
      );
    });

    test('Fragment + query: keep the same href, do not double https://', () {
      const html =
          'View https://example.com/page?query=1#section and https://a.b/c#frag';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(
        out,
        contains(
          '<a href="https://example.com/page?query=1#section">https://example.com/page?query=1#section</a>',
        ),
      );
      expect(
        out,
        contains('<a href="https://a.b/c#frag">https://a.b/c#frag</a>'),
      );
    });

    test('Do not wrap in <code> and <pre>', () {
      const html = '<pre>https://example.com</pre> <code>www.site.com</code>';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(out, contains('<pre>https://example.com</pre>'));
      expect(out, contains('<code>www.site.com</code>'));
      expect(out, isNot(contains('<pre><a ')));
      expect(out, isNot(contains('<code><a ')));
    });

    test('Do not wrap javascript: and data:', () {
      const html = 'javascript:alert(1) and data:text/html;base64,AAAA';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(out, isNot(contains('<a ')));
      expect(out, contains('javascript:alert(1)'));
      expect(out, contains('data:text/html;base64,AAAA'));
    });

    test('Do not wrap URLs in attributes', () {
      const html = '<img src="https://example.com/img.png">';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(out, equals('<img src="https://example.com/img.png">'));
    });

    test('IP addresses: http + www.*', () {
      const html = 'http://192.168.1.1 www.127.0.0.1';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(out, contains('<a href="http://192.168.1.1">http://192.168.1.1</a>'));
      expect(out, contains('<a href="https://www.127.0.0.1">www.127.0.0.1</a>'));
    });

    test('URLs in blockquote/list/table are wrapped', () {
      const html = '''
      <blockquote>https://example.com</blockquote>
      <ul><li>www.site.com</li></ul>
      <table><tr><td>https://abc.com</td></tr></table>
      ''';
      final out = HtmlUtils.wrapPlainTextLinks(html).replaceAll('\n', '');

      expect(
        out,
        contains(
          '<blockquote><a href="https://example.com">https://example.com</a></blockquote>',
        ),
      );
      expect(
        out,
        contains('<li><a href="https://www.site.com">www.site.com</a></li>'),
      );
      expect(
        out,
        contains('<td><a href="https://abc.com">https://abc.com</a></td>'),
      );
    });

    test('Malformed URLs: no wrap', () {
      const html = 'Wrong: http//example and www..com';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(out, isNot(contains('<a href')));
      expect(out, contains('http//example'));
      expect(out, contains('www..com'));
    });

    test('Adjacent links without spaces: will now wrap into ONE link', () {
      const html = 'www.example1.comwww.example2.com';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(
        out,
        contains(
          '<a href="https://www.example1.comwww.example2.com">www.example1.comwww.example2.com</a>',
        ),
      );
      expect(out.indexOf('<a '), greaterThanOrEqualTo(0));
      expect(out.indexOf('<a ', out.indexOf('<a ') + 1), equals(-1));
    });

    test('Do not wrap when already in <a> (skip parent tag)', () {
      const html =
          '<a href="https://example.com">https://example.com</a> và www.site.com';
      final out = HtmlUtils.wrapPlainTextLinks(html);

      expect(
        out,
        contains(
          '<a href="https://example.com">https://example.com</a>',
        ),
      );
      expect(
        out,
        contains('<a href="https://www.site.com">www.site.com</a>'),
      );
    });
  });
}