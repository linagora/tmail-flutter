import 'package:flutter_test/flutter_test.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:universal_html/html.dart' as html;

void main() {
  group('HtmlUtils generateHtmlDocument', () {
    test('appends custom styleCSS after all default styles', () {
      const customCss = 'div { color: red; }';

      final result = HtmlUtils.generateHtmlDocument(
        content: '<p>Test</p>',
        styleCSS: customCss,
      );

      expect(result, contains(customCss));
      final lastDefaultRuleIndex = result.indexOf('word-break: normal !important');
      final customCssIndex = result.indexOf(customCss);
      expect(lastDefaultRuleIndex, greaterThan(-1));
      expect(customCssIndex, greaterThan(lastDefaultRuleIndex),
        reason: 'custom styleCSS must appear after default CSS so it can override');
    });

    test('generates valid HTML document structure with required meta tags', () {
      final result = HtmlUtils.generateHtmlDocument(content: '<p>Hello</p>');

      expect(result, contains('<!DOCTYPE html>'));
      expect(result, contains('<html>'));
      expect(result, contains('width=device-width, initial-scale=1.0'));
      expect(result, contains('charset=utf-8'));
      expect(result, contains('<div class="tmail-content">'));
      expect(result, contains('<p>Hello</p>'));
    });

    test('generates document without custom styleCSS when param is omitted', () {
      final result = HtmlUtils.generateHtmlDocument(content: '<p>Test</p>');

      expect(result, contains('word-break: normal !important'));
    });

    test('includes box-sizing border-box reset to prevent border overflow', () {
      final result = HtmlUtils.generateHtmlDocument(content: '<p>Test</p>');

      expect(result, contains('box-sizing: border-box'));
    });
  });

  group('HtmlUtils addQuoteToggle tests', () {
    test('Should add toggle button to HTML with single blockquote', () {
      const htmlInput = '''
        <div>
          <blockquote>
            <p>Quoted text</p>
          </blockquote>
        </div>
      ''';

      final result = HtmlUtils.addQuoteToggle(htmlInput);
      
      expect(result, contains('quote-toggle-container'));
      expect(result, contains('quote-toggle-button'));
    });

    test('Should handle nested blockquotes by modifying deepest level', () {
      const htmlInput = '''
        <div>
          <blockquote class="outer">
            <div>
              <blockquote class="inner">
                <p>Nested quote</p>
              </blockquote>
            </div>
          </blockquote>
        </div>
      ''';

      final result = HtmlUtils.addQuoteToggle(htmlInput);
      final document = html.DomParser().parseFromString(result, 'text/html');
      
      expect(
        document.querySelector('.quote-toggle-button')?.nextElementSibling,
        document.querySelector('.outer'),
      );
    });

    test('Should return original string when input is not HTML', () {
      const plainText = 'This is just plain text without any HTML tags';
      final result = HtmlUtils.addQuoteToggle(plainText);
      expect(result, plainText);
    });

    test('Should handle invalid HTML gracefully', () {
      const malformedHtml = '''
        <div>
          <blockquote>
            <p>Unclosed tag
          </blockquote>
        </div>
      ''';

      final result = HtmlUtils.addQuoteToggle(malformedHtml);
      expect(result, isNot(equals(malformedHtml)));
      expect(result, contains('quote-toggle-button'));
    });

    test('Should preserve existing content when adding toggle', () {
      const htmlInput = '''
        <div class="email-body">
          <p>Hello World</p>
          <blockquote>
            <p>Previous message</p>
          </blockquote>
        </div>
      ''';

      final result = HtmlUtils.addQuoteToggle(htmlInput);
      final container = html.DivElement()..innerHtml = result;
      expect(container.querySelector('.email-body'), isNotNull);
      expect(container.querySelector('p')?.text, contains('Hello World'));
      expect(container.querySelector('blockquote p')?.text, contains('Previous message'));
    });
  });

  group('HtmlUtils buildFileLinkCard tests', () {
    test('Should build anchor tag with href, title and action label', () {
      final result = HtmlUtils.buildFileLinkCard(
        href: 'https://example.com/file',
        title: 'My File',
        actionLabel: 'Open in drive',
        iconZoneHtml: '<div>icon</div>',
      );

      expect(result, startsWith('<a href="https://example.com/file"'));
      expect(result, contains('target="_blank"'));
      expect(result, contains('rel="noopener noreferrer"'));
      expect(result, contains('<div>icon</div>'));
      expect(result, contains('title="My File">My File</div>'));
      expect(result, contains('Open in drive ↗'));
      expect(result, endsWith('</a>'));
    });

    test('Should apply custom card width and min height', () {
      final result = HtmlUtils.buildFileLinkCard(
        href: 'https://example.com/file',
        title: 'My File',
        actionLabel: 'Open in drive',
        iconZoneHtml: '',
        cardWidthPx: 200,
        cardMinHeightPx: 100,
      );

      expect(result, contains('width:200px'));
      expect(result, contains('min-height:100px'));
    });
  });

  group('HtmlUtils buildFileCardIconZone tests', () {
    test('Should render an image tag with the given imageUrl as src', () {
      final result = HtmlUtils.buildFileCardIconZone(imageUrl: 'https://example.com/thumb.png');

      expect(result, contains('<img src="https://example.com/thumb.png"'));
      expect(result, contains('width="60" height="60"'));
    });

    test('Should render an image tag with empty src when imageUrl is null', () {
      final result = HtmlUtils.buildFileCardIconZone();

      expect(result, contains('<img src=""'));
      expect(result, contains('<div style='));
    });

    test('Should apply custom icon zone height and icon size', () {
      final result = HtmlUtils.buildFileCardIconZone(
        imageUrl: 'https://example.com/thumb.png',
        iconZoneHeightPx: 120,
        iconSizePx: 80,
      );

      expect(result, contains('height:120px'));
      expect(result, contains('width="80" height="80"'));
    });
  });

  group('HtmlUtils wrapFileCardsHtml tests', () {
    test('Should return empty string when cardsHtml is empty', () {
      final result = HtmlUtils.wrapFileCardsHtml('');

      expect(result, isEmpty);
    });

    test('Should wrap cardsHtml in a block-level div followed by a line break', () {
      const cardsHtml = '<a>card1</a><a>card2</a>';

      final result = HtmlUtils.wrapFileCardsHtml(cardsHtml);

      expect(result, '<div style="display:block;max-width:100%;">$cardsHtml</div><br>');
    });
  });
}
