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
}