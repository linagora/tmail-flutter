import 'package:core/presentation/validator/sane_html_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sane_html_validator test', () {

    test('sanitize should return clean html not contain style attribute', () async {

      final saneHtmlValidator = SaneHtmlValidator(
        allowAttributes: null,
        allowClassName: null,
        allowElementId: null,
        addLinkRel: null
      );

      final cleanHtml = saneHtmlValidator.sanitize('<a style="background-color: #FF0000" class="className" id="idElement" href="javascript:alert()">Hello</a>');

      expect(cleanHtml, isNot(contains('style')));
      expect(cleanHtml, isNot(contains('className')));
      expect(cleanHtml, isNot(contains('idElement')));
      expect(cleanHtml, isNot(contains('href')));
    });

    test('sanitize should return clean html contain style attribute', () async {

      final saneHtmlValidator = SaneHtmlValidator(
          allowAttributes: (attribute) => attribute == 'style',
          allowClassName: null,
          allowElementId: null,
          addLinkRel: null
      );

      final cleanHtml = saneHtmlValidator.sanitize('<a style="background-color: #FF0000">Hello</a>');

      expect(cleanHtml, contains('style'));
    });

    test('sanitize should return clean html contain test class name', () async {

      final saneHtmlValidator = SaneHtmlValidator(
          allowAttributes: null,
          allowClassName: (className) => className == 'test',
          allowElementId: null,
          addLinkRel: null
      );

      final cleanHtml = saneHtmlValidator.sanitize('<span class="test">Hello</span');

      expect(cleanHtml, contains('test'));
    });

    test('sanitize should return clean html contain test element id', () async {

      final saneHtmlValidator = SaneHtmlValidator(
          allowAttributes: null,
          allowClassName: null,
          allowElementId: (elementId) => elementId == 'test',
          addLinkRel: null
      );

      final cleanHtml = saneHtmlValidator.sanitize('<span id="test">Hello</span');

      expect(cleanHtml, contains('test'));
    });

    test('sanitize should return clean html contain rel="nofollow" in tag', () async {

      final saneHtmlValidator = SaneHtmlValidator(
          allowAttributes: null,
          allowClassName: null,
          allowElementId: null,
          addLinkRel: (href) => href == 'http://example.com/test.jpg' ? ['nofollow'] : null,
      );

      final cleanHtml = saneHtmlValidator.sanitize('<a href="http://example.com/test.jpg">Hello</a>');

      expect(cleanHtml, contains('rel="nofollow"'));
    });
  });
}