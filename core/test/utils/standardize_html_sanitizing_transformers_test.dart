import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';

void main() {
  group('StandardizeHtmlSanitizingTransformers.process', () {
    const transformer = StandardizeHtmlSanitizingTransformers();
    const htmlEscape = HtmlEscape();

    const allowedTags = <String>[
      'div',
      'span',
      'p',
      'a',
      'i',
      'table',
      'font',
      'u',
      'center',
      'section',
    ];

    const eventAttributes = <String>[
      'mousedown',
      'mouseenter',
      'mouseleave',
      'mousemove',
      'mouseover',
      'mouseout',
      'mouseup',
      'load',
      'unload',
      'loadstart',
      'loadeddata',
      'loadedmetadata',
      'playing',
      'show',
      'error',
      'message',
      'focus',
      'focusin',
      'focusout',
      'keydown',
      'keypress',
      'keyup',
      'input',
      'ended',
      'drag',
      'drop',
      'dragstart',
      'dragover',
      'dragleave',
      'dragend',
      'dragenter',
      'beforeunload',
      'beforeprint',
      'afterprint',
      'blur',
      'click',
      'change',
      'contextmenu',
      'cut',
      'copy',
      'dblclick',
      'abort',
      'durationchange',
      'progress',
      'resize',
      'reset',
      'scroll',
      'seeked',
      'select',
      'submit',
      'toggle',
      'volumechange',
      'touchstart',
      'touchmove',
      'touchend',
      'touchcancel',
    ];

    String sanitize(String input) =>
        transformer.process(input, htmlEscape).trim();

    group('Event attributes, script, iframe – fully sanitized', () {
      test('SHOULD remove all on* event attributes from IMG WHEN event attributes exist', () {
        for (final evt in eventAttributes) {
          final html = '<img src="1" href="1" on$evt="javascript:alert(1)">';
          expect(sanitize(html), equals('<img src="1">'));
        }
      });

      test('SHOULD remove all on* event attributes FROM any allowed tag FOR all events', () {
        for (final tag in allowedTags) {
          for (final evt in eventAttributes) {
            final html = '<$tag on$evt="javascript:alert(1)"></$tag>';
            expect(sanitize(html), equals('<$tag></$tag>'));
          }
        }
      });

      test('SHOULD remove all on* event attributes FROM <colgroup>', () {
        for (final evt in eventAttributes) {
          final html = '<table><colgroup on$evt="javascript:alert(1)"></colgroup></table>';
          expect(sanitize(html), equals('<table><colgroup></colgroup></table>'));
        }
      });

      test('SHOULD remove all on* event attributes FROM <col>', () {
        for (final evt in eventAttributes) {
          final html =
              '<table><colgroup><col on$evt="javascript:alert(1)"></colgroup></table>';
          expect(sanitize(html),
              equals('<table><colgroup><col></colgroup></table>'));
        }
      });

      test('SHOULD remove <script> elements entirely', () {
        expect(sanitize('<script>alert("x")</script>'), equals(''));
      });

      test('SHOULD remove <iframe> elements entirely', () {
        expect(sanitize('<iframe onmouseover="prompt(1)"></iframe>'), equals(''));
      });

      test('SHOULD remove nested <script> elements', () {
        const html = '<div><p>Hello<script>alert(1)</script></p></div>';
        expect(sanitize(html), equals('<div><p>Hello</p></div>'));
      });
    });

    group('Href/src sanitization – unsafe removed, safe preserved', () {
      test('SHOULD remove javascript: href FROM <a>', () {
        const html = '<a href="javascript:alert(1)" id="id1">test</a>';
        expect(sanitize(html), equals('<a id="id1">test</a>'));
      });

      test('SHOULD remove invalid JS event attributes FROM <img>', () {
        const html = '<img src="1" href="1" onerror="javascript:alert(1)">';
        expect(sanitize(html), equals('<img src="1">'));
      });

      test('SHOULD keep base64 image sources intact', () {
        const html = '<img src="data:image/jpeg;base64,AAAABBBBCCCC==">';
        expect(
            sanitize(html),
            equals('<img src="data:image/jpeg;base64,AAAABBBBCCCC==">'));
      });

      test('SHOULD keep cid: image sources intact', () {
        expect(
            sanitize('<img src="cid:email123">'),
            equals('<img src="cid:email123">'));
      });
    });

    group('Unknown tags, structural tags – unwrap or preserve safely', () {
      test('SHOULD preserve nav/main/footer but strip dangerous attributes', () {
        expect(sanitize('<nav href="javascript:1"></nav>'), equals('<nav></nav>'));
        expect(sanitize('<main href="javascript:1"></main>'), equals('<main></main>'));
        expect(sanitize('<footer href="javascript:1"></footer>'), equals('<footer></footer>'));
      });

      test('SHOULD unwrap <supress_time_adjustment> AND keep children', () {
        const html =
            '<supress_time_adjustment href="javascript:1"><div><p>Hello</p></div></supress_time_adjustment>';
        expect(sanitize(html), equals('<div><p>Hello</p></div>'));
      });

      test('SHOULD unwrap <google-sheets-html-origin> AND keep children', () {
        const html =
            '<google-sheets-html-origin href="javascript:1"><div><p>Hello</p></div></google-sheets-html-origin>';
        expect(sanitize(html), equals('<div><p>Hello</p></div>'));
      });

      test('SHOULD unwrap unknown tags AND keep children', () {
        expect(sanitize('<custom><p>Hello</p></custom>'), equals('<p>Hello</p>'));
      });

      test('SHOULD unwrap nested unknown tags AND keep children', () {
        expect(
            sanitize('<x1><x2><p>Hello</p></x2></x1>'),
            equals('<p>Hello</p>'));
      });
    });

    group('CSS sanitization – unsafe styles removed', () {
      test('SHOULD keep plain text containing JS-like keywords', () {
        const html = 'hello <p>document.cookie</p> world';

        expect(
          sanitize(html),
          equals('hello <p>document.cookie</p> world'),
        );
      });

      test('SHOULD remove HTML comments entirely', () {
        const html = '<div><!--test--><p>A</p><!--x--></div>';
        expect(sanitize(html), equals('<div><p>A</p></div>'));
      });

      test('SHOULD remove unsafe CSS FROM <style>', () {
        const html =
            '<style>p{position:absolute;color:red;background:url(javascript:evil);}</style>';
        expect(sanitize(html), equals(''));
      });

      test('SHOULD sanitize inline CSS by removing dangerous properties', () {
        const html =
            '<p style="color:red;position:absolute;background:url(javascript:evil)">X</p>';
        expect(sanitize(html), equals('<p style="color: red">X</p>'));
      });
    });

    group('ID and class validation – valid preserved, invalid removed', () {
      test('SHOULD preserve valid id/class values', () {
        const html = '<div id="abc123" class="valid_class"></div>';
        expect(
            sanitize(html),
            equals('<div id="abc123" class="valid_class"></div>'));
      });

      test('SHOULD remove invalid id/class values', () {
        const html = '<div id="!!!" class="@@@"></div>';
        expect(sanitize(html), equals('<div></div>'));
      });
    });

    group('Complex nested HTML – sanitized safely', () {
      test('SHOULD remove all dangerous content AND preserve safe nodes', () {
        const html = '''
          <div onclick="x">
            <p>Hello<script>alert(1)</script></p>
            <img src="cid:x1" onerror="hack()">
            <a href="javascript:evil()" id="ok">link</a>
          </div>
        ''';

        final out = sanitize(html);

        expect(out.contains('javascript'), false);
        expect(out.contains('hack'), false);
        expect(out.contains('script'), false);
        expect(out.contains('evil'), false);
        expect(out.contains('onclick'), false);
        expect(out.contains('<img'), true);
        expect(out.contains('<div'), true);
        expect(out.contains('<a'), true);
        expect(out.contains('Hello'), true);
      });
    });

    group('FORM attributes – dangerous removed', () {
      final dangerousFormAttributes = [
        'action="https://malicious.com/x"',
        'action="javascript:1"',
        'method="POST"',
        'target="_blank"',
        'enctype="multipart/form-data"',
        'formaction="https://evil.com"',
        'formmethod="POST"',
        'formtarget="_blank"',
        'formenctype="text/plain"',
        'autocomplete="off"',
        'novalidate',
        'accept-charset="UTF-8"',
        'name="myForm"',
      ];

      test('SHOULD remove every dangerous FORM attribute', () {
        for (final attr in dangerousFormAttributes) {
          final html = '<form $attr></form>';
          expect(sanitize(html), equals(''));
        }
      });
    });

    group('FORM child elements – all removed', () {
      final forbiddenChildren = [
        '<input type="text">',
        '<input type="password">',
        '<input type="hidden">',
        '<input type="file">',
        '<button>Submit</button>',
        '<textarea></textarea>',
        '<select><option>A</option></select>',
        '<option>A</option>',
      ];

      test('SHOULD remove dangerous FORM child elements', () {
        for (final child in forbiddenChildren) {
          expect(sanitize('<form>$child</form>'), equals(''));
        }
      });
    });

    group('FORM combined vectors – fully sanitized', () {
      test('SHOULD remove dangerous FORM attributes AND dangerous children', () {
        const html =
            '<form action="https://evil.com" method="POST"><input type="text"></form>';
        expect(sanitize(html), equals(''));
      });

      test('SHOULD remove multiple dangerous items inside complex FORM', () {
        const html = '''
          <form action="javascript:1" method="POST">
            <input type="text">
            <input type="password">
            <button>Submit</button>
          </form>
        ''';

        final out = sanitize(html);
        expect(out.contains('input'), isFalse);
        expect(out.contains('button'), isFalse);
        expect(out.contains('action'), isFalse);
        expect(out.contains('method'), isFalse);
      });

      test('SHOULD remove nested FORM elements', () {
        const html = '<form action="outer"><form action="inner"></form></form>';
        final out = sanitize(html);
        expect(out.contains('action'), isFalse);
      });

      test('SHOULD keep safe nested elements even when FORM wrapper is removed', () {
        const html =
            '<form action="test"><div><div><p>Content</p></div></div></form>';
        final out = sanitize(html);
        expect(out.contains('action'), isFalse);
        expect(out.contains('<p>'), isTrue);
      });
    });

    group('FORM safe attributes – safely unwrapped', () {
      test('SHOULD unwrap FORM with safe style', () {
        expect(sanitize('<form style="color: red;"></form>'), contains(''));
      });

      test('SHOULD unwrap FORM with safe class', () {
        expect(sanitize('<form class="email-form"></form>'), contains(''));
      });

      test('SHOULD unwrap FORM with safe id', () {
        expect(sanitize('<form id="my-form"></form>'), contains(''));
      });

      test('SHOULD unwrap FORM with safe bgcolor', () {
        expect(sanitize('<form bgcolor="#fff"></form>'), contains(''));
      });

      test('SHOULD remove dangerous attributes even when safe attributes exist', () {
        const html =
            '<form style="color:red;" action="https://evil" class="a" method="POST"></form>';
        final out = sanitize(html);
        expect(out.contains('style'), isFalse);
        expect(out.contains('class'), isFalse);
        expect(out.contains('action'), isFalse);
        expect(out.contains('method'), isFalse);
      });

      test('SHOULD preserve nested safe elements when FORM wrapper is removed', () {
        const html =
            '<form><div><p>Safe</p><table><tr><td>X</td></tr></table></div></form>';
        final out = sanitize(html);
        expect(out.contains('<div>'), isTrue);
        expect(out.contains('Safe'), isTrue);
        expect(out.contains('<table>'), isTrue);
      });
    });

    group('Real-world phishing/XSS form attacks – fully sanitized', () {
      test('SHOULD remove credential phishing forms', () {
        const html = '''
          <form action="https://attacker.com" method="POST">
            <input type="text">
            <input type="password">
            <button>Login</button>
          </form>
        ''';

        final out = sanitize(html);
        expect(out.contains('action'), isFalse);
        expect(out.contains('input'), isFalse);
        expect(out.contains('button'), isFalse);
      });

      test('SHOULD prevent CSRF token stealing by removing hidden inputs', () {
        const html =
            '<form action="https://bank.com"><input type="hidden" name="csrf"></form>';
        final out = sanitize(html);
        expect(out.contains('input'), isFalse);
        expect(out.contains('csrf'), isFalse);
      });

      test('SHOULD remove javascript-based form actions', () {
        expect(sanitize('<form action="javascript:alert(1)"></form>'), equals(''));
      });

      test('SHOULD remove data URI form actions', () {
        expect(sanitize('<form action="data:text/html,<script>x</script>"></form>'),
            equals(''));
      });

      test('SHOULD prevent file upload exploitation', () {
        const html =
            '<form action="/upload" enctype="multipart/form-data"><input type="file"></form>';
        final out = sanitize(html);
        expect(out.contains('input'), isFalse);
        expect(out.contains('enctype'), isFalse);
      });

      test('SHOULD allow safe cosmetic FORM usage while removing wrapper', () {
        const html = '''
          <form style="border:1px solid #ccc">
            <div><p>This is a survey notification</p></div>
          </form>
        ''';

        final out = sanitize(html);
        expect(out.contains('<form'), isFalse);
        expect(out.contains('style'), isFalse);
        expect(out.contains('This is a survey notification'), isTrue);
        expect(out.contains('<div'), isTrue);
        expect(out.contains('<p'), isTrue);
      });

      test('SHOULD remove mixed XSS and phishing vectors inside FORM', () {
        const html = '''
          <form action="https://evil.com" onsubmit="alert(1)">
            <script>steal()</script>
            <input type="text" onclick="hack()">
            <iframe src="x"></iframe>
          </form>
        ''';

        final out = sanitize(html);
        expect(out.contains('action'), isFalse);
        expect(out.contains('onsubmit'), isFalse);
        expect(out.contains('script'), isFalse);
        expect(out.contains('input'), isFalse);
        expect(out.contains('iframe'), isFalse);
      });
    });
  });
}
