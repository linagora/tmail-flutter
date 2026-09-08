import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/mapper/workplace_intent_mapper.dart';

void main() {
  Map<String, dynamic> buildResponse({
    required String id,
    List<String> hrefs = const ['https://drive.example.com/pick'],
    String? client,
  }) => {
    'data': {
      'id': id,
      'attributes': {
        'action': 'PICK',
        'type': 'files',
        'permissions': ['GET'],
        'services': [for (final href in hrefs) {'href': href}],
        if (client != null) 'client': client,
      },
    },
  };

  group('WorkplaceIntentMapper::parseIntentResponse::', () {
    test('Should return WorkplaceIntent with correct id and url', () {
      final result = parseIntentResponse(
        buildResponse(id: 'intent-1'),
        requireHttps: false,
      );

      expect(result.intentId, equals('intent-1'));
      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/pick')));
    });

    test('Should parse JSON string input', () {
      const jsonString =
          '{"data":{"id":"intent-str","attributes":{"action":"PICK","type":"files","permissions":["GET"],"services":[{"href":"https://drive.example.com/str"}]}}}';

      final result = parseIntentResponse(
        jsonString,
        requireHttps: false,
      );

      expect(result.intentId, equals('intent-str'));
      expect(result.intentUrl.host, equals('drive.example.com'));
    });

    test('Should throw StateError when services list is empty', () {
      expect(
        () => parseIntentResponse(
          buildResponse(id: 'intent-1', hrefs: []),
          requireHttps: false,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('Should throw FormatException for unsupported input type', () {
      expect(
        () => parseIntentResponse(42, requireHttps: false),
        throwsA(isA<FormatException>()),
      );
    });

    test('Should throw ArgumentError when requireHttps is true and URL is http', () {
      expect(
        () => parseIntentResponse(
          buildResponse(id: 'intent-1', hrefs: ['http://drive.example.com/pick']),
          requireHttps: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Should accept http URL when requireHttps is false', () {
      final result = parseIntentResponse(
        buildResponse(id: 'intent-1', hrefs: ['http://drive.example.com/pick']),
        requireHttps: false,
      );

      expect(result.intentUrl.scheme, equals('http'));
    });

    test('Should use kReleaseMode as default for requireHttps', () {
      // In debug/test mode, kReleaseMode is false so http URLs are accepted
      if (kReleaseMode) {
        expect(
          () => parseIntentResponse(
            buildResponse(id: 'intent-1', hrefs: ['http://drive.example.com/pick']),
          ),
          throwsA(isA<ArgumentError>()),
        );
      } else {
        expect(
          parseIntentResponse(
            buildResponse(id: 'intent-1', hrefs: ['http://drive.example.com/pick']),
          ),
          isNotNull,
        );
      }
    });

    test('Should parse client from attributes when present', () {
      final result = parseIntentResponse(
        buildResponse(id: 'intent-1', client: 'client-abc'),
        requireHttps: false,
      );

      expect(result.client, equals('client-abc'));
    });

    test('Should have null client when attributes omit it', () {
      final result = parseIntentResponse(
        buildResponse(id: 'intent-1'),
        requireHttps: false,
      );

      expect(result.client, isNull);
    });

    test('Should use first service href when multiple services are present', () {
      final result = parseIntentResponse(
        buildResponse(
          id: 'intent-multi',
          hrefs: [
            'https://drive.example.com/first',
            'https://drive.example.com/second',
          ],
        ),
        requireHttps: false,
      );

      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/first')));
    });
  });
}
