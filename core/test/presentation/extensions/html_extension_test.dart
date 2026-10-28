import 'package:core/presentation/extensions/html_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlNullableExtension::', () {
    test('escapeHtmlString should escapes HTML containing onclick attribute', () {
      String? input = "<a onclick=\"alert('hi')\">Click</a>";
      expect(input.escapeHtmlString(),
          '&lt;a onclick=&quot;alert(&#39;hi&#39;)&quot;&gt;Click&lt;&#47;a&gt;');
    });

    test('escapeHtmlString should escapes HTML containing multiple events', () {
      String? input = "<div onmouseover=\"alert('hover')\" onclick=\"doSomething()\">Hover</div>";
      expect(input.escapeHtmlString(),
          '&lt;div onmouseover=&quot;alert(&#39;hover&#39;)&quot; onclick=&quot;doSomething()&quot;&gt;Hover&lt;&#47;div&gt;');
    });

    test('escapeLtGtHtmlString should escapes only < and > with events', () {
      String? input = "<button onclick=\"run()\">Run</button>";
      expect(input.escapeLtGtHtmlString(),
          '&lt;button onclick=\"run()\"&gt;Run&lt;/button&gt;');
    });

    test('escapeHtmlString should handles HTML with empty event attributes', () {
      String? input = "<img src=\"image.png\" onerror=\"\">";
      expect(input.escapeHtmlString(),
          '&lt;img src=&quot;image.png&quot; onerror=&quot;&quot;&gt;');
    });

    test('escapeHtmlString should handles HTML with invalid syntax in events', () {
      String? input = "<a onclick=\"alert('unclosed event)>Click</a>";
      expect(input.escapeHtmlString(),
          '&lt;a onclick=&quot;alert(&#39;unclosed event)&gt;Click&lt;&#47;a&gt;');
    });
  });

  group('HtmlExtension::hasNoTextContent', () {
    test('returns true for empty string', () {
      expect(''.hasNoTextContent, isTrue);
    });

    test('returns true for markup that only holds line breaks', () {
      expect('<p><br></p>'.hasNoTextContent, isTrue);
      expect('<div><br></div>'.hasNoTextContent, isTrue);
      expect('<br>'.hasNoTextContent, isTrue);
    });

    test('returns true for whitespace and nbsp only', () {
      expect('<div> &nbsp; \u00a0 </div>'.hasNoTextContent, isTrue);
    });

    test('returns false when the markup holds text', () {
      expect('<p>Hello</p>'.hasNoTextContent, isFalse);
    });

    test('returns false when the markup holds an image', () {
      expect('<div><img src="a.png"></div>'.hasNoTextContent, isFalse);
    });

    test('returns false when the image tag is upper case', () {
      expect('<DIV><IMG SRC="a.png"></DIV>'.hasNoTextContent, isFalse);
    });

    test('returns true for nbsp entities without any tag', () {
      expect('&nbsp;&nbsp;'.hasNoTextContent, isTrue);
    });

    test('returns false for plain text without any tag', () {
      expect('Back soon'.hasNoTextContent, isFalse);
    });

    test('returns false for escaped markup typed as text', () {
      expect('<p>&lt;br&gt;</p>'.hasNoTextContent, isFalse);
    });

    test('returns false for text holding an unclosed angle bracket', () {
      expect('<div>< </div>'.hasNoTextContent, isFalse);
    });
  });
}
