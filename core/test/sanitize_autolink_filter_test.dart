import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/sanitize_autolink_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SanitizeAutolinkFilter test', () {

    final sanitizeAutolinkFilter = SanitizeAutolinkFilter(const HtmlEscape());

    test(
      'SanitizeAutolinkFilter should return html a tag with href="urlLink" when input text contain https',
      () {
        final htmlValidate = sanitizeAutolinkFilter.process('See https://linagora.com at Hanoi');
        expect(
          htmlValidate,
          equals('See <a href="https://linagora.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">linagora.com</a> at Hanoi')
        );
      }
    );

    test(
      'SanitizeAutolinkFilter should return html a tag with href="urlLink" when input text contain http',
      () {
        final htmlValidate = sanitizeAutolinkFilter.process('See http://linagora.com at Hanoi');
        expect(
          htmlValidate,
          equals('See <a href="http://linagora.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">linagora.com</a> at Hanoi')
        );
      }
    );

    test(
      'SanitizeAutolinkFilter should return html a tag with href="urlLink" when input text contain www',
      () {
        final htmlValidate = sanitizeAutolinkFilter.process('See www.linagora.com at Hanoi');
        expect(
          htmlValidate,
          equals('See <a href="https://www.linagora.com" target="_blank" rel="noreferrer" style="white-space: nowrap; word-break: keep-all;">linagora.com</a> at Hanoi')
        );
      }
    );

    test(
      'SanitizeAutolinkFilter should return html a tag with href="mailToLink" when input text contain email address',
      () {
        final htmlValidate = sanitizeAutolinkFilter.process('See tdvu@linagora.com at Hanoi');
        expect(
          htmlValidate,
          equals('See <a href="mailto:tdvu@linagora.com" style="white-space: nowrap; word-break: keep-all;">tdvu@linagora.com</a> at Hanoi')
        );
      }
    );
  });
}