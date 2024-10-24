import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('StandardizeHtmlSanitizingTransformers::test', () {
    const transformer = StandardizeHtmlSanitizingTransformers();
    const htmlEscape = HtmlEscape();

    test('SHOULD remove all `on*` attributes tag', () {
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
        'keydpress',
        'keydup',
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
        'touchcancel'
      ];

      for (var i = 0; i < listOnEventAttributes.length; i++) {
        final inputHtml = '<img src="1" href="1" on${listOnEventAttributes[i]}="javascript:alert(1)">';
        final result = transformer.process(inputHtml, htmlEscape);

        expect(result, equals('<img src="1">'));
      }
    });

    test('SHOULD remove all `on*` attributes for any tags', () {
      const listOnEventAttributes = [
        'mousedown', 'mouseenter', 'mouseleave', 'mousemove', 'mouseover',
        'mouseout', 'mouseup', 'load', 'unload', 'loadstart', 'loadeddata',
        'loadedmetadata', 'playing', 'show', 'error', 'message', 'focus',
        'focusin', 'focusout', 'keydown', 'keypress', 'keyup', 'input', 'ended',
        'drag', 'drop', 'dragstart', 'dragover', 'dragleave', 'dragend', 'dragenter',
        'beforeunload', 'beforeprint', 'afterprint', 'blur', 'click', 'change',
        'contextmenu', 'cut', 'copy', 'dblclick', 'abort', 'durationchange',
        'progress', 'resize', 'reset', 'scroll', 'seeked', 'select', 'submit',
        'toggle', 'volumechange', 'touchstart', 'touchmove', 'touchend', 'touchcancel'
      ];

      const listHTMLTags = [
        'div', 'span', 'p', 'a', 'u', 'i', 'table'
      ];

      for (var tag in listHTMLTags) {
        for (var event in listOnEventAttributes) {
          final inputHtml = '<$tag on$event="javascript:alert(1)"></$tag>';
          final result = transformer.process(inputHtml, htmlEscape);

          expect(result, equals('<$tag></$tag>'));
        }
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
  });
}
