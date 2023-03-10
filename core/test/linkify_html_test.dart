
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

    test(
      'generateLinkify should preserve the text when input text contain <a href=',
      () async {
        final htmlValidate = linkifyHtml.generateLinkify(
          'Check console output at "<a href="https://ci-builds.apache.org/job/james/job/ApacheJames/job/master/765/">james/ApacheJames/master [master] [765]</a>"'
        );
        expect(
          htmlValidate,
          equals('Check console output at "<a href="https://ci-builds.apache.org/job/james/job/ApacheJames/job/master/765/">james/ApacheJames/master [master] [765]</a>"')
        );
      }
    );
  });
}