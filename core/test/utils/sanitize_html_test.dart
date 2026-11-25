import 'package:core/presentation/utils/html_transformer/sanitize_html.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SanitizeHtml.process', () {
    for (final href in ['https://', 'https:%2f/[::1]']) {
      test('should drop the hostless href "$href" and keep the link text', () {
        final output = SanitizeHtml().process(inputHtml: '<a href="$href">link</a>');

        expect(output, '<a>link</a>');
      });
    }

    test('should keep an absolute https href', () {
      final output = SanitizeHtml().process(inputHtml: '<a href="https://example.com">link</a>');

      expect(output, '<a href="https://example.com">link</a>');
    });
  });
}
