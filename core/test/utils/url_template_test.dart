import 'package:core/utils/url_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlTemplate', () {
    final resolveCases = <({
      String description,
      UrlTemplate template,
      Map<String, String?> variables,
      Set<String> caseInsensitiveVariables,
      String expected,
    })>[
      (
        description: 'resolve raw and encoded placeholders',
        template: UrlTemplate(
          'https://calendar.example.com/events/{UID}/%7Buid%7D',
        ),
        variables: const {'uid': 'event-42'},
        caseInsensitiveVariables: const {'uid'},
        expected: 'https://calendar.example.com/events/event-42/event-42',
      ),
      (
        description:
            'resolve encoded placeholders with lowercase or mixed-case markers',
        template: UrlTemplate(
          'https://%7blocalPart%7D.%7BdomainName%7d/events/%7buId%7D',
        ),
        variables: const {
          'localPart': 'john',
          'domainName': 'example.com',
          'uid': 'event-42',
        },
        caseInsensitiveVariables: const {'uid'},
        expected: 'https://john.example.com/events/event-42',
      ),
      (
        description: 'treat unselected encoded placeholders as literals',
        template: UrlTemplate.withSelectedEncodedPlaceholders(
          'https://calendar.example.com/events/{UID}/%7Buid%7D',
          encodedPlaceholderNames: const {},
        ),
        variables: const {'uid': 'event-42'},
        caseInsensitiveVariables: const {'uid'},
        expected: 'https://calendar.example.com/events/event-42/%7Buid%7D',
      ),
      (
        description: 'resolve only selected encoded placeholders',
        template: UrlTemplate.withSelectedEncodedPlaceholders(
          'https://%7bLOCALPART%7D.%7BDomainname%7d/events/{UID}/%7BuId%7D',
          encodedPlaceholderNames: const {'localPart', 'domainName'},
        ),
        variables: const {
          'localPart': 'john',
          'domainName': 'example.com',
          'uid': 'event-42',
        },
        caseInsensitiveVariables: const {
          'localPart',
          'domainName',
          'uid',
        },
        expected: 'https://john.example.com/events/event-42/%7BuId%7D',
      ),
      (
        description: 'not reinterpret replacement values as placeholders',
        template: UrlTemplate('/{localPart}/{domainName}/{UID}'),
        variables: const {
          'localPart': '{UID}',
          'domainName': '%7Buid%7D',
          'uid': 'event-42',
        },
        caseInsensitiveVariables: const {'uid'},
        expected: '/{UID}/%7Buid%7D/event-42',
      ),
    ];

    for (final testCase in resolveCases) {
      test('SHOULD ${testCase.description}', () {
        expect(
          testCase.template.resolve(
            variables: testCase.variables,
            caseInsensitiveVariables: testCase.caseInsensitiveVariables,
          ),
          testCase.expected,
        );
      });
    }

    test('SHOULD return null WHEN a used variable is unavailable', () {
      expect(
        UrlTemplate('https://{domainName}/events')
            .resolve(variables: const {'domainName': null}),
        isNull,
      );
    });

    test('SHOULD leave a template unchanged WHEN variables are unused', () {
      expect(
        UrlTemplate('https://calendar.example.com/events')
            .resolve(variables: const {'domainName': null}),
        'https://calendar.example.com/events',
      );
    });

    test('SHOULD scan a long malformed template without recursion', () {
      final malformedTemplate = '${List.filled(100000, 'a').join()}{';

      expect(
        UrlTemplate(malformedTemplate).hasOnlySupportedPlaceholders(
          names: const {},
        ),
        isFalse,
      );
    });

    test('SHOULD render a large valid template iteratively', () {
      final template = List.filled(10000, '/{uid}/%7Buid%7D').join();
      final expected = List.filled(10000, '/event-42/event-42').join();

      expect(
        UrlTemplate(template).resolve(
          variables: const {'uid': 'event-42'},
        ),
        expected,
      );
    });

    test('SHOULD reject long malformed encoded input without recursion', () {
      final malformedTemplate = '${List.filled(100000, 'a').join()}%7Buid';

      expect(
        UrlTemplate(malformedTemplate).hasOnlySupportedPlaceholders(
          names: const {'uid'},
        ),
        isFalse,
      );
    });

    test('SHOULD reject malformed or unsupported placeholders', () {
      for (final template in [
        'https://calendar.example.com/{}',
        'https://calendar.example.com/{uid',
        'https://calendar.example.com/uid}',
        'https://calendar.example.com/{outer{uid}}',
        'https://calendar.example.com/%7B%7D',
        'https://calendar.example.com/%7Buid',
        'https://calendar.example.com/uid%7D',
        'https://calendar.example.com/%7Bouter%7Buid%7D%7D',
        'https://calendar.example.com/{uid%7D',
        'https://calendar.example.com/%7Buid}',
        'https://calendar.example.com/{domain}',
      ]) {
        expect(
          UrlTemplate(template).hasOnlySupportedPlaceholders(
            names: const {'localPart', 'domainName'},
            caseInsensitiveNames: const {'uid'},
          ),
          isFalse,
        );
      }
    });
  });
}
