
import 'package:core/utils/linkify_html.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('linkify_html test', () {

    final linkifyHtml = LinkifyHtml();

    test(
        'generateLinkify should return <a href="url" target="_blank">url</a> when input text contain http/https/ftp',
        () async {
            final htmlValidate = linkifyHtml.generateLinkify(
                'See <https://linagora.com> at Hanoi'
            );
            expect(
                htmlValidate,
                equals('See <<a href="https://linagora.com" target="_blank">https://linagora.com</a>> at Hanoi'));
        }
    );

    test(
        'generateLinkify should return <a href="https://www" target="_blank">www</a> when input text contain www',
            () async {
          final htmlValidate = linkifyHtml.generateLinkify(
              'See www.google.com at Hanoi'
          );
          expect(
              htmlValidate,
              equals('See <a href="https://www.google.com" target="_blank">www.google.com</a> at Hanoi'));
        }
    );

    test(
        'generateLinkify should return <a href="mailto:url">url</a> when input text contain email address',
            () async {
          final htmlValidate = linkifyHtml.generateLinkify(
              'See tdvu@linagora.com at Hanoi'
          );
          expect(
              htmlValidate,
              equals('See <a href="mailto:tdvu@linagora.com">tdvu@linagora.com</a> at Hanoi'));
        }
    );
  });
}