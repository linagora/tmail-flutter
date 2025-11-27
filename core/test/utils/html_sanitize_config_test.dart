import 'package:core/presentation/utils/html_transformer/html_sanitize_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUp(() {
    dotenv.testLoad();
  });

  group('HtmlSanitizeConfig.loadPreservedHtmlTags', () {
    test('returns empty list when env variable is missing', () {
      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(result, isEmpty);
    });

    test('returns empty list when env variable is empty string', () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE': '',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(result, isEmpty);
    });

    test('returns empty list when env only contains spaces', () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE': '   ',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(result, isEmpty);
    });

    test('parses a valid comma-separated list of tags', () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE': 'form,section,figure',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(result, ['form', 'section', 'figure']);
    });

    test('trims whitespace around tags', () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE': ' form , section  ,   figure ',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(result, ['form', 'section', 'figure']);
    });

    test('ignores empty entries after splitting', () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE': 'form,, ,section,,',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(result, ['form', 'section']);
    });

    test('parses tags containing hyphens, underscores, and uppercase letters',
        () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE':
            'CUSTOM-TAG, custom_tag , MyTag , X-LARGE, label_item',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(
        result,
        [
          'CUSTOM-TAG',
          'custom_tag',
          'MyTag',
          'X-LARGE',
          'label_item',
        ],
      );
    });

    test('handles mixed-case and special-character tags with extra spaces', () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE':
            '  My-Tag  ,  MY_TAG ,   ultra-WIDE   ,Test_TAG  ',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(
        result,
        [
          'My-Tag',
          'MY_TAG',
          'ultra-WIDE',
          'Test_TAG',
        ],
      );
    });

    test('removes duplicate tags even with different spacing', () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE':
            'form,  form , FORM,   form  , section , SECTION ',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(
        result,
        [
          'form',
          'FORM',
          'section',
          'SECTION',
        ],
      );
    });

    test('parses tags containing numbers', () {
      dotenv.testLoad(mergeWith: {
        'EMAIL_HTML_TAGS_TO_PRESERVE':
            'tag123, v2-tag, item_01, BLOCK100, x-apple-123',
      });

      final result = HtmlSanitizeConfig.loadPreservedHtmlTags();

      expect(
        result,
        [
          'tag123',
          'v2-tag',
          'item_01',
          'BLOCK100',
          'x-apple-123',
        ],
      );
    });
  });
}
