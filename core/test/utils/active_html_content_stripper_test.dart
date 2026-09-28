import 'package:core/utils/html/active_html_content_stripper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActiveHtmlContentStripper.strip', () {
    String strip(String html) => ActiveHtmlContentStripper.strip(html);

    test('SHOULD remove script and frame elements', () {
      final out = strip('<p>Hi</p><script>alert(1)</script><iframe src="https://x"></iframe>'
          '<object data="x"></object><embed src="x"><form action="https://x"><input></form>');

      expect(out, contains('<p>Hi</p>'));
      for (final tag in ['<script', '<iframe', '<object', '<embed', '<form', '<input']) {
        expect(out.toLowerCase(), isNot(contains(tag)));
      }
    });

    test('SHOULD remove event handlers and srcdoc', () {
      final out = strip('<img src="https://x/a.png" onerror="alert(1)">'
          '<div onclick="x()" onmouseover="y()">text</div>');

      expect(out.toLowerCase(), isNot(contains('onerror')));
      expect(out.toLowerCase(), isNot(contains('onclick')));
      expect(out.toLowerCase(), isNot(contains('onmouseover')));
      expect(out, contains('src="https://x/a.png"'));
    });

    test('SHOULD remove script URLs, including obfuscated ones', () {
      final out = strip('<a href="javascript:alert(1)">a</a>'
          '<a href=" jav&#x09;ascript:alert(1)">b</a>'
          '<a href="data:text/html,<script>alert(1)</script>">c</a>');

      expect(out.toLowerCase(), isNot(contains('javascript')));
      expect(out.toLowerCase(), isNot(contains('data:text')));
    });

    test('SHOULD keep formatting, links, cid and data images', () {
      const html = '<div style="color: red; float: left"><b>bold</b> '
          '<a href="https://example.com" target="_blank">link</a> '
          '<a href="mailto:a@b.c">mail</a>'
          '<img src="cid:abc@x" id="cid:abc@x" data-mimetype="image/png">'
          '<img src="data:image/png;base64,iVBORw0KGgo=" alt="x"></div>';

      final out = strip(html);

      expect(out, contains('style="color: red; float: left"'));
      expect(out, contains('<b>bold</b>'));
      expect(out, contains('href="https://example.com"'));
      expect(out, contains('href="mailto:a@b.c"'));
      expect(out, contains('src="cid:abc@x"'));
      expect(out, contains('id="cid:abc@x"'));
      expect(out, contains('src="data:image/png;base64,iVBORw0KGgo="'));
    });

    test('SHOULD remove scripts nested in SVG', () {
      final out = strip('<svg><script>alert(1)</script><a xlink:href="javascript:alert(1)">'
          '<text>t</text></a><animate onbegin="alert(1)"></animate></svg>');

      expect(out.toLowerCase(), isNot(contains('<script')));
      expect(out.toLowerCase(), isNot(contains('javascript')));
      expect(out.toLowerCase(), isNot(contains('onbegin')));
    });

    test('SHOULD return empty content unchanged', () {
      expect(strip(''), '');
    });
  });
}
