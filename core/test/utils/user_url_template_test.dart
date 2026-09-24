import 'package:core/utils/user_url_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserUrlTemplate', () {
    group('placeholder matrix', () {
      const templateCases = [
        (
          description: 'no identity placeholders',
          parts: <_TemplatePart>{},
          expected: 'https://calendar.example.com/events',
        ),
        (
          description: 'localPart only',
          parts: {_TemplatePart.localPart},
          expected: 'https://johndoe.example.com/events',
        ),
        (
          description: 'domainName only',
          parts: {_TemplatePart.domainName},
          expected: 'https://calendar.example.com/events',
        ),
        (
          description: 'localPart and domainName',
          parts: {_TemplatePart.localPart, _TemplatePart.domainName},
          expected: 'https://johndoe.example.com/events',
        ),
      ];

      for (final syntax in _PlaceholderSyntax.values) {
        for (final testCase in templateCases) {
          test(
            'SHOULD resolve ${testCase.description} WITH ${syntax.name} syntax',
            () {
              expect(
                UserUrlTemplate(
                  _userUrlTemplate(syntax, testCase.parts),
                ).resolve(ownerEmail: 'john.doe@example.com'),
                testCase.expected,
              );
            },
          );
        }
      }
    });

    test('SHOULD share normalized local-part and domain-name variables', () {
      expect(
        UserUrlTemplate(
          'https://{domainName}/users/{localPart}',
        ).resolve(ownerEmail: 'john.doe@example.com'),
        'https://example.com/users/johndoe',
      );
    });

    test('SHOULD resolve user placeholders with lowercase encoded markers', () {
      expect(
        UserUrlTemplate(
          'https://%7blocalPart%7D.%7BdomainName%7d/events',
        ).resolve(ownerEmail: 'john.doe@example.com'),
        'https://johndoe.example.com/events',
      );
    });

    test('SHOULD resolve case-insensitive identity variables WHEN requested', () {
      expect(
        UserUrlTemplate('{localpart}-calendar.{DOMAINNAME}').resolve(
          ownerEmail: 'john.doe@example.com',
          caseInsensitiveVariables: UserUrlTemplateVariables.names,
        ),
        'johndoe-calendar.example.com',
      );
    });

    test('SHOULD prefer an explicit domain name', () {
      expect(
        UserUrlTemplate('https://{localPart}.{domainName}/events')
            .resolve(
              ownerEmail: 'john.doe@example.com',
              domainName: 'calendar.example.com',
            ),
        'https://johndoe.calendar.example.com/events',
      );
    });

    test('SHOULD not replace an explicit empty domain name', () {
      expect(
        UserUrlTemplate('https://{domainName}/events').resolve(
          ownerEmail: 'john.doe@example.com',
          domainName: '',
        ),
        isNull,
      );
    });

    const unavailableOwnerCases = <({String description, String? value})>[
      (description: 'missing', value: null),
      (description: 'empty', value: ''),
      (description: 'blank', value: '   '),
      (description: 'malformed', value: 'invalid'),
    ];

    for (final ownerCase in unavailableOwnerCases) {
      for (final placeholderName in UserUrlTemplateVariables.names) {
        test(
          'SHOULD return null for $placeholderName WHEN owner email is ${ownerCase.description}',
          () {
            expect(
              UserUrlTemplate('https://calendar.example.com/{$placeholderName}')
                  .resolve(ownerEmail: ownerCase.value),
              isNull,
            );
          },
        );
      }
    }

    test('SHOULD resolve domainName from an explicit value without owner email', () {
      expect(
        UserUrlTemplate('https://{domainName}/events').resolve(
          domainName: 'tenant.example.com',
        ),
        'https://tenant.example.com/events',
      );
    });

    test('SHOULD ignore unavailable identity WHEN the template does not use it', () {
      expect(
        UserUrlTemplate('https://calendar.example.com/events').resolve(),
        'https://calendar.example.com/events',
      );
    });

    test('SHOULD not resolve the unsupported domain alias', () {
      expect(
        UserUrlTemplate('https://{domain}/events')
            .resolve(ownerEmail: 'john.doe@example.com'),
        'https://{domain}/events',
      );
    });

    test('SHOULD not reinterpret a placeholder-like identity value', () {
      expect(
        UserUrlTemplate('/users/{localPart}/events/{UID}').resolve(
          ownerEmail: '{uid}@example.com',
          variables: const {'uid': 'event-42'},
          caseInsensitiveVariables: const {'uid'},
        ),
        '/users/{uid}/events/event-42',
      );
    });

    test('SHOULD trim owner email before resolving identity', () {
      expect(
        UserUrlTemplate('https://{localPart}.{domainName}').resolve(
          ownerEmail: '  john.doe@example.com  ',
        ),
        'https://johndoe.example.com',
      );
    });
  });
}

enum _PlaceholderSyntax { raw, encoded }

enum _TemplatePart { localPart, domainName }

String _userUrlTemplate(
  _PlaceholderSyntax syntax,
  Set<_TemplatePart> parts,
) {
  final localPart = parts.contains(_TemplatePart.localPart)
      ? '${_placeholder(UserUrlTemplateVariables.localPart, syntax)}.'
      : 'calendar.';
  final domainName = parts.contains(_TemplatePart.domainName)
      ? _placeholder(UserUrlTemplateVariables.domainName, syntax)
      : 'example.com';
  return 'https://$localPart$domainName/events';
}

String _placeholder(String name, _PlaceholderSyntax syntax) =>
    switch (syntax) {
      _PlaceholderSyntax.raw => '{$name}',
      _PlaceholderSyntax.encoded => Uri.encodeComponent('{$name}'),
    };
