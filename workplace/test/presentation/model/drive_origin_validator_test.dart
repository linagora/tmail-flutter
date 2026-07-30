import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/presentation/model/drive_origin_validator.dart';

const _origin = 'https://drive.example.com';
const _otherOrigin = 'https://evil.example.com';
const _client = 'client-xyz';

void main() {
  group('WebDriveOriginValidator', () {
    const validator = WebDriveOriginValidator();

    test('null origin → false', () {
      expect(
        validator.isValid(null, intentOrigin: _origin, intentClient: null),
        isFalse,
      );
    });

    test('origin matches intentOrigin → true', () {
      expect(
        validator.isValid(_origin, intentOrigin: _origin, intentClient: null),
        isTrue,
      );
    });

    test('mismatched origin → false', () {
      expect(
        validator.isValid(_otherOrigin, intentOrigin: _origin, intentClient: null),
        isFalse,
      );
    });

    test('origin matches intentClient but not intentOrigin → false (web ignores client)', () {
      expect(
        validator.isValid(_client, intentOrigin: _origin, intentClient: _client),
        isFalse,
      );
    });

    test('data: URI intent (intentOrigin "null") accepts "*"', () {
      expect(
        validator.isValid('*', intentOrigin: 'null', intentClient: null),
        isTrue,
      );
    });

    test('"*" rejected when intentOrigin is not "null"', () {
      expect(
        validator.isValid('*', intentOrigin: _origin, intentClient: null),
        isFalse,
      );
    });
  });

  group('MobileDriveOriginValidator', () {
    const validator = MobileDriveOriginValidator();

    test('null origin → false', () {
      expect(
        validator.isValid(null, intentOrigin: _origin, intentClient: _client),
        isFalse,
      );
    });

    test('origin matches intentOrigin → true', () {
      expect(
        validator.isValid(_origin, intentOrigin: _origin, intentClient: _client),
        isTrue,
      );
    });

    test('origin matches intentClient (not intentOrigin) → true', () {
      expect(
        validator.isValid(_client, intentOrigin: _origin, intentClient: _client),
        isTrue,
      );
    });

    test('origin matches neither intentOrigin nor intentClient → false', () {
      expect(
        validator.isValid(_otherOrigin, intentOrigin: _origin, intentClient: _client),
        isFalse,
      );
    });

    test('intentClient null → client branch never matches', () {
      expect(
        validator.isValid(_otherOrigin, intentOrigin: _origin, intentClient: null),
        isFalse,
      );
    });

    test('data: URI intent (intentOrigin "null") accepts "*"', () {
      expect(
        validator.isValid('*', intentOrigin: 'null', intentClient: null),
        isTrue,
      );
    });

    test('wildcard intentClient does not match wildcard origin on HTTPS intent → false', () {
      expect(
        validator.isValid('*', intentOrigin: _origin, intentClient: '*'),
        isFalse,
      );
    });

    test('blank/whitespace intentClient never matches → false', () {
      expect(
        validator.isValid('   ', intentOrigin: _origin, intentClient: '   '),
        isFalse,
      );
    });

    test('valid non-wildcard intentClient still matches (unchanged behavior)', () {
      expect(
        validator.isValid(_client, intentOrigin: _origin, intentClient: _client),
        isTrue,
      );
    });
  });

  group('isValidDriveClient', () {
    test('null → false', () {
      expect(isValidDriveClient(null), isFalse);
    });

    test('empty string → false', () {
      expect(isValidDriveClient(''), isFalse);
    });

    test('whitespace-only → false', () {
      expect(isValidDriveClient('   '), isFalse);
    });

    test('wildcard "*" → false', () {
      expect(isValidDriveClient('*'), isFalse);
    });

    test('valid client id → true', () {
      expect(isValidDriveClient(_client), isTrue);
    });
  });
}
