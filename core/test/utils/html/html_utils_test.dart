import 'package:flutter_test/flutter_test.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:universal_html/html.dart' as html;

void main() {
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
}
