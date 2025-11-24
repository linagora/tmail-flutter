import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/labels.dart';
import 'package:labels/method/set/set_label_method.dart';
import 'package:labels/method/set/set_label_response.dart';

import '../method_fixtures.dart';

void main() {
  group('SetLabelMethod', () {
    final accountId = AccountId(
      Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6'),
    );

    Map<String, dynamic> buildPayload(Map<String, dynamic> createMap) {
      return {
        "using": [
          "urn:ietf:params:jmap:core",
          "com:linagora:params:jmap:labels"
        ],
        "methodCalls": [
          [
            "Label/set",
            {
              "accountId": accountId.id.value,
              "create": createMap,
            },
            "c0"
          ]
        ]
      };
    }

    test('should deserialize SetLabelResponse correctly', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "session-state",
          "methodResponses": [
            [
              "Label/set",
              {
                "accountId": accountId.id.value,
                "oldState": "old",
                "newState": "new",
                "created": {
                  "4f29": {"id": "123456", "keyword": "important"}
                }
              },
              "c0"
            ]
          ]
        }),
        data: buildPayload({
          "4f29": {"displayName": "Important", "color": "#00ccdd"}
        }),
        headers: {"accept": "application/json;jmapVersion=rfc-8621"},
      );

      final builder = createBuilder(dio);
      final method = SetLabelMethod(accountId)
        ..addCreate(
          Id('4f29'),
          Label(
            displayName: 'Important',
            color: HexColor('#00ccdd'),
          ),
        );

      final invocation = builder.invocation(method);

      // Act
      final response = await (builder..usings(method.requiredCapabilities))
          .build()
          .execute();

      final parsed = response.parse<SetLabelResponse>(
        invocation.methodCallId,
        SetLabelResponse.deserialize,
      );

      // Assert
      expect(parsed, isNotNull);
      expect(parsed!.created![Id('4f29')]!.keyword, equals('important'));
    });

    test('should process multiple created labels', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "S",
          "methodResponses": [
            [
              "Label/set",
              {
                "accountId": accountId.id.value,
                "newState": "S2",
                "created": {
                  "A": {"id": "111", "keyword": "tagA"},
                  "B": {"id": "222", "keyword": "tagB"}
                }
              },
              "c0"
            ]
          ]
        }),
        data: buildPayload({
          "A": {"displayName": "Tag A", "color": "#111111"},
          "B": {"displayName": "Tag B", "color": "#222222"},
        }),
      );

      final builder = createBuilder(dio);

      final method = SetLabelMethod(accountId)
        ..addCreate(
            Id('A'), Label(displayName: "Tag A", color: HexColor("#111111")))
        ..addCreate(
            Id('B'), Label(displayName: "Tag B", color: HexColor("#222222")));

      final invocation = builder.invocation(method);

      // Act
      final response = await (builder..usings(method.requiredCapabilities))
          .build()
          .execute();

      final parsed = response.parse<SetLabelResponse>(
        invocation.methodCallId,
        SetLabelResponse.deserialize,
      );

      // Assert
      expect(parsed, isNotNull);
      expect(parsed!.created!.length, equals(2));
      expect(parsed.created![Id('A')]!.keyword, equals('tagA'));
      expect(parsed.created![Id('B')]!.keyword, equals('tagB'));
    });

    test('should throw DioException when backend returns 500', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(500, {}),
        data: buildPayload({
          "A": {"displayName": "Err", "color": "#dddddd"}
        }),
      );

      final builder = createBuilder(dio);

      final method = SetLabelMethod(accountId)
        ..addCreate(
          Id("A"),
          Label(displayName: "Err", color: HexColor("#dddddd")),
        );

      // Act
      final call =
          (builder..usings(method.requiredCapabilities)).build().execute();

      // Assert
      expect(call, throwsA(isA<DioError>()));
    });
  });
}
