import 'package:flutter_test/flutter_test.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/html/file_link_card_html_builder.dart';
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

  group('HtmlUtils registerFileLinkRowEnterKeyHandler tests', () {
    test('Should return a stable script name regardless of platform', () {
      final web = HtmlUtils.registerFileLinkRowEnterKeyHandler(isWebPlatform: true);
      final mobile = HtmlUtils.registerFileLinkRowEnterKeyHandler(isWebPlatform: false);

      expect(web.name, 'registerFileLinkRowEnterKeyHandler');
      expect(mobile.name, 'registerFileLinkRowEnterKeyHandler');
    });

    test('Should target the Summernote editable root when isWebPlatform is true', () {
      final result = HtmlUtils.registerFileLinkRowEnterKeyHandler(isWebPlatform: true);

      expect(result.script, contains('const isWebPlatform = true'));
      expect(result.script, contains(".note-editor .note-editable'"));
    });

    test('Should target the mobile editor root when isWebPlatform is false', () {
      final result = HtmlUtils.registerFileLinkRowEnterKeyHandler(isWebPlatform: false);

      expect(result.script, contains('const isWebPlatform = false'));
      expect(result.script, contains("'#editor'"));
    });

    test('Should identify a file-link card row only via a direct tmail-file-link-card anchor child', () {
      final result = HtmlUtils.registerFileLinkRowEnterKeyHandler();

      expect(result.script, contains("classList.contains('tmail-file-link-card')"));
      expect(result.script, contains('firstElementChild'));
    });

    test('Should split the row into two at the caret index rather than always inserting after it', () {
      final result = HtmlUtils.registerFileLinkRowEnterKeyHandler();

      expect(result.script, contains('function splitRowAt'));
      expect(result.script, contains('function getSplitIndex'));
      expect(result.script, contains('cloneNode(false)'));
    });

    test('Should fall back to a blank line before/after the row at its edges instead of an empty split', () {
      final result = HtmlUtils.registerFileLinkRowEnterKeyHandler();

      expect(result.script, contains('function placeCaretInAdjacentLine'));
      expect(result.script, contains('function hasCard'));
      expect(result.script, contains('if (!hasCard(before))'));
      expect(result.script, contains('if (!hasCard(after))'));
    });

    test('Should reuse an existing empty adjacent line instead of stacking a new one', () {
      final result = HtmlUtils.registerFileLinkRowEnterKeyHandler();

      expect(result.script, contains('function isEmptyBlock'));
      expect(result.script, contains('if (!isEmptyBlock(target))'));
    });
  });

  group('HtmlUtils extractPlainText file link card tests', () {
    final card = FileLinkCardHtmlBuilder.buildFileLinkCard(
      const FileLinkCardContent(
        href: 'https://drive.example.com/file/1',
        title: 'report_attachment.pdf',
        actionLabel: 'Open in Drive',
        iconZoneHtml: '',
      ),
    );

    test('Should strip file link card title/action text by default', () {
      final result = HtmlUtils.extractPlainText('<p>Hello there</p>$card');

      expect(result, contains('Hello there'));
      expect(result, isNot(contains('report_attachment.pdf')));
      expect(result, isNot(contains('Open in Drive')));
    });

    test('Should keep file link card text when removeFileLinkCards is false', () {
      final result = HtmlUtils.extractPlainText(
        '<p>Hello there</p>$card',
        removeFileLinkCards: false,
      );

      expect(result, contains('Hello there'));
      expect(result, contains('report_attachment.pdf'));
      expect(result, contains('Open in Drive'));
    });

    test('Should still detect user-typed attachment mentions outside the card', () {
      final result = HtmlUtils.extractPlainText(
        '<p>I forgot the attachment</p>$card',
      );

      expect(result, contains('I forgot the attachment'));
      expect(result, isNot(contains('report_attachment.pdf')));
    });
  });
}
