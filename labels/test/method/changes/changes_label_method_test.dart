import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:labels/method/changes/changes_label_method.dart';
import 'package:labels/method/changes/changes_label_response.dart';

import '../method_fixtures.dart';

void main() {
  group('ChangesLabelMethod', () {
    const accountIdString =
        '29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6';
    const oldStateString = '2c9f1b12-b35a-43e6-9af2-0106fb53a943';

    final accountId = AccountId(Id(accountIdString));
    final oldState = State(oldStateString);

    Map<String, dynamic> buildPayload() {
      return {
        "using": [
          "urn:ietf:params:jmap:core",
          "com:linagora:params:jmap:labels",
        ],
        "methodCalls": [
          [
            "Label/changes",
            {
              "accountId": accountId.id.value,
              "sinceState": oldStateString,
            },
            "c0",
          ]
        ]
      };
    }

    test('should parse ChangesLabelResponse correctly', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "S",
          "methodResponses": [
            [
              "Label/changes",
              {
                "accountId": accountIdString,
                "oldState": oldStateString,
                "newState": "NEW-STATE-XYZ",
                "hasMoreChanges": false,
                "created": ["123456"],
                "updated": ["654321"],
                "destroyed": []
              },
              "c0",
            ]
          ]
        }),
        data: buildPayload(),
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = ChangesLabelMethod(accountId, oldState);
      final invocation = builder.invocation(method);

      // Act
      final response = await (builder..usings(method.requiredCapabilities))
          .build()
          .execute();

      final parsed = response.parse<ChangesLabelResponse>(
        invocation.methodCallId,
        ChangesLabelResponse.deserialize,
      );

      // Assert
      expect(parsed, isNotNull);
      expect(parsed!.created, hasLength(1));
      expect(parsed.updated, hasLength(1));
      expect(parsed.destroyed, isEmpty);
      expect(parsed.hasMoreChanges, isFalse);
    });

    test('should handle empty created/updated/destroyed lists', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "S",
          "methodResponses": [
            [
              "Label/changes",
              {
                "accountId": accountIdString,
                "oldState": oldStateString,
                "newState": "newState-000",
                "hasMoreChanges": false,
                "created": [],
                "updated": [],
                "destroyed": [],
              },
              "c0"
            ]
          ]
        }),
        data: buildPayload(),
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = ChangesLabelMethod(accountId, oldState);
      final invocation = builder.invocation(method);

      // Act
      final response = await (builder..usings(method.requiredCapabilities))
          .build()
          .execute();

      final parsed = response.parse<ChangesLabelResponse>(
        invocation.methodCallId,
        ChangesLabelResponse.deserialize,
      );

      // Assert
      expect(parsed!.created, isEmpty);
      expect(parsed.updated, isEmpty);
      expect(parsed.destroyed, isEmpty);
    });

    test('should parse hasMoreChanges = true correctly', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "S",
          "methodResponses": [
            [
              "Label/changes",
              {
                "accountId": accountIdString,
                "oldState": oldStateString,
                "newState": "X2",
                "hasMoreChanges": true,
                "created": ["1"],
                "updated": [],
                "destroyed": [],
              },
              "c0"
            ]
          ]
        }),
        data: buildPayload(),
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = ChangesLabelMethod(accountId, oldState);
      final invocation = builder.invocation(method);

      // Act
      final response = await (builder..usings(method.requiredCapabilities))
          .build()
          .execute();

      final parsed = response.parse<ChangesLabelResponse>(
        invocation.methodCallId,
        ChangesLabelResponse.deserialize,
      );

      // Assert
      expect(parsed!.hasMoreChanges, isTrue);
      expect(parsed.created, contains(Id("1")));
    });

    test('should throw DioException on server error', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(500, {}),
        data: buildPayload(),
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = ChangesLabelMethod(accountId, oldState);

      // Act
      final call =
          (builder..usings(method.requiredCapabilities)).build().execute();

      // Assert
      expect(call, throwsA(isA<DioException>()));
    });
  });
}
