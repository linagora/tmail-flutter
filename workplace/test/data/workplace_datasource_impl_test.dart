import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';

void main() {
  late WorkplaceDataSourceImpl datasource;

  setUp(() {
    datasource = WorkplaceDataSourceImpl();
  });

  Map<String, dynamic> buildResponse({
    required String id,
    required String href,
  }) => {
    'data': {
      'id': id,
      'attributes': {
        'action': 'PICK',
        'type': 'files',
        'permissions': ['GET'],
        'services': [
          {'href': href},
        ],
      },
    },
  };

  group('WorkplaceDataSourceImpl::parseIntentResponse::', () {
    test('Should return WorkplaceIntent with correct id and url', () {
      final result = datasource.parseIntentResponse(
        buildResponse(id: 'intent-1', href: 'https://drive.example.com/pick'),
        requireHttps: false,
      );

      expect(result.intentId, equals('intent-1'));
      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/pick')));
    });

    test('Should parse JSON string input', () {
      const jsonString =
          '{"data":{"id":"intent-str","attributes":{"action":"PICK","type":"files","permissions":["GET"],"services":[{"href":"https://drive.example.com/str"}]}}}';

      final result = datasource.parseIntentResponse(
        jsonString,
        requireHttps: false,
      );

      expect(result.intentId, equals('intent-str'));
      expect(result.intentUrl.host, equals('drive.example.com'));
    });

    test('Should throw StateError when services list is empty', () {
      final data = {
        'data': {
          'id': 'intent-1',
          'attributes': {
            'action': 'PICK',
            'type': 'files',
            'permissions': ['GET'],
            'services': <dynamic>[],
          },
        },
      };

      expect(
        () => datasource.parseIntentResponse(data, requireHttps: false),
        throwsA(isA<StateError>()),
      );
    });

    test('Should throw FormatException for unsupported input type', () {
      expect(
        () => datasource.parseIntentResponse(42, requireHttps: false),
        throwsA(isA<FormatException>()),
      );
    });

    test('Should throw ArgumentError when requireHttps is true and URL is http', () {
      expect(
        () => datasource.parseIntentResponse(
          buildResponse(id: 'intent-1', href: 'http://drive.example.com/pick'),
          requireHttps: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Should accept http URL when requireHttps is false', () {
      final result = datasource.parseIntentResponse(
        buildResponse(id: 'intent-1', href: 'http://drive.example.com/pick'),
        requireHttps: false,
      );

      expect(result.intentUrl.scheme, equals('http'));
    });

    test('Should use kReleaseMode as default for requireHttps', () {
      // In debug/test mode, kReleaseMode is false so http URLs are accepted
      if (kReleaseMode) {
        expect(
          () => datasource.parseIntentResponse(
            buildResponse(id: 'intent-1', href: 'http://drive.example.com/pick'),
          ),
          throwsA(isA<ArgumentError>()),
        );
      } else {
        expect(
          datasource.parseIntentResponse(
            buildResponse(id: 'intent-1', href: 'http://drive.example.com/pick'),
          ),
          isNotNull,
        );
      }
    });

    test('Should use first service href when multiple services are present', () {
      final data = {
        'data': {
          'id': 'intent-multi',
          'attributes': {
            'action': 'PICK',
            'type': 'files',
            'permissions': ['GET'],
            'services': [
              {'href': 'https://drive.example.com/first'},
              {'href': 'https://drive.example.com/second'},
            ],
          },
        },
      };

      final result = datasource.parseIntentResponse(data, requireHttps: false);

      expect(result.intentUrl, equals(Uri.parse('https://drive.example.com/first')));
    });
  });
}
