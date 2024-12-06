import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('StandardizeHtmlSanitizingTransformers::test', () {
    const transformer = StandardizeHtmlSanitizingTransformers();
    const htmlEscape = HtmlEscape();
    const listHTMLTags = [
      'div',
      'span',
      'p',
      'a',
      'i',
      'table',
      'font',
      'u',
      'center',
      'style',
      'section',
      'google-sheets-html-origin',
    ];
    const listOnEventAttributes = [
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

    test('SHOULD remove all `on*` attributes tag', () {
      for (var i = 0; i < listOnEventAttributes.length; i++) {
        final inputHtml = '<img src="1" href="1" on${listOnEventAttributes[i]}="javascript:alert(1)">';
        final result = transformer.process(inputHtml, htmlEscape);

        expect(result, equals('<img src="1">'));
      }
    });

    test('SHOULD remove all `on*` attributes for any tags', () {
      for (var tag in listHTMLTags) {
        for (var event in listOnEventAttributes) {
          final inputHtml = '<$tag on$event="javascript:alert(1)"></$tag>';
          final result = transformer.process(inputHtml, htmlEscape);

          expect(result, equals('<$tag></$tag>'));
        }
      }
    });

    test('SHOULD remove all `on*` attributes for `colgroup` tag', () {
      for (var event in listOnEventAttributes) {
        final inputHtml = '<table><colgroup on$event="javascript:alert(1)"></colgroup></table>';
        final result = transformer.process(inputHtml, htmlEscape);

        expect(result, equals('<table><colgroup></colgroup></table>'));
      }
    });

    test('SHOULD remove all `on*` attributes for `col` tag', () {
      for (var event in listOnEventAttributes) {
        final inputHtml = '<table><colgroup><col on$event="javascript:alert(1)"></colgroup></table>';
        final result = transformer.process(inputHtml, htmlEscape);

        expect(result, equals('<table><colgroup><col></colgroup></table>'));
      }
    });

    test('SHOULD remove attributes of IMG tag WHEN they are invalid', () {
      const inputHtml = '<img src="1" href="1" onerror="javascript:alert(1)">';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<img src="1">'));
    });

    test('SHOULD remove all SCRIPTS tags', () {
      const inputHtml = '<script>alert("This is an alert message!");</script>';
      final result = transformer.process(inputHtml, htmlEscape).trim();

      expect(result, equals(''));
    });

    test('SHOULD remove all IFRAME tags', () {
      const inputHtml = '<iframe style="xg-p:absolute;top:0;left:0;width:100%;height:100%" onmouseover="prompt(1)">';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals(''));
    });

    test('SHOULD remove href attribute of A tag WHEN it is invalid', () {
      const inputHtml = '<a href="javascript:alert(1)" id="id1">test</a>';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<a id="id1">test</a>'));
    });

    test('SHOULD persist value src attribute of IMG tag WHEN it is base64 string', () {
      const inputHtml = '<img src="data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA">';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<img src="data:image/jpeg;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA">'));
    });

    test('SHOULD persist value src attribute of IMG tag WHEN it is CID string', () {
      const inputHtml = '<img src="cid:email123">';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<img src="cid:email123">'));
    });

    test(
      'SHOULD persist nav tag and remove href attribute of A tag '
      'WHEN href is invalid',
    () {
      const inputHtml = '<nav href="javascript:alert(1)"></nav>';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<nav></nav>'));
    });

    test(
      'SHOULD persist main tag and remove href attribute of A tag '
      'WHEN href is invalid',
    () {
      const inputHtml = '<main href="javascript:alert(1)"></main>';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<main></main>'));
    });

    test(
      'SHOULD persist footer tag and remove href attribute of A tag '
      'WHEN href is invalid',
    () {
      const inputHtml = '<footer href="javascript:alert(1)"></footer>';
      final result = transformer.process(inputHtml, htmlEscape);

      expect(result, equals('<footer></footer>'));
    });
  });
}
