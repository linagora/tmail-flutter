import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/labels.dart';

import '../method_fixtures.dart';

void main() {
  group('GetLabelMethod', () {
    final accountId = AccountId(
      Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6'),
    );

    Map<String, dynamic> buildRequestPayload({
      required List<String> ids,
    }) {
      return {
        "using": [
          "urn:ietf:params:jmap:core",
          "com:linagora:params:jmap:labels"
        ],
        "methodCalls": [
          [
            "Label/get",
            {
              "accountId": accountId.id.value,
              "ids": ids,
            },
            "c0"
          ]
        ]
      };
    }

    test('should return all labels when none are notFound', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      final labelA = Label(
        id: Id('A'),
        keyword: KeyWordIdentifier('labelA'),
        displayName: 'Label A',
        color: HexColor('#111111'),
      );
      final labelB = Label(
        id: Id('B'),
        keyword: KeyWordIdentifier('labelB'),
        displayName: 'Label B',
        color: HexColor('#222222'),
      );

      adapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": "state",
            "methodResponses": [
              [
                "Label/get",
                {
                  "accountId": accountId.id.value,
                  "state": "s1",
                  "list": [
                    {
                      "id": "A",
                      "displayName": "Label A",
                      "keyword": "labelA",
                      "color": "#111111",
                    },
                    {
                      "id": "B",
                      "displayName": "Label B",
                      "keyword": "labelB",
                      "color": "#222222",
                    }
                  ],
                  "notFound": []
                },
                "c0"
              ]
            ]
          },
        ),
        data: buildRequestPayload(ids: ['A', 'B']),
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = GetLabelMethod(accountId)..addIds({Id('A'), Id('B')});
      final invocation = builder.invocation(method);

      // Act
      final response = await (builder..usings(method.requiredCapabilities))
          .build()
          .execute();

      final parsed = response.parse<GetLabelResponse>(
        invocation.methodCallId,
        GetLabelResponse.deserialize,
      );

      // Assert
      expect(parsed!.list, containsAll({labelA, labelB}));
      expect(parsed.notFound, isEmpty);
    });

    test('should return notFound only when no labels exist', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": "state",
            "methodResponses": [
              [
                "Label/get",
                {
                  "accountId": accountId.id.value,
                  "state": "s1",
                  "list": [],
                  "notFound": ["X1", "X2"]
                },
                "c0"
              ]
            ]
          },
        ),
        data: buildRequestPayload(ids: ['X1', 'X2']),
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = GetLabelMethod(accountId)..addIds({Id('X1'), Id('X2')});
      final invocation = builder.invocation(method);

      // Act
      final response = await (builder..usings(method.requiredCapabilities))
          .build()
          .execute();

      final parsed = response.parse<GetLabelResponse>(
        invocation.methodCallId,
        GetLabelResponse.deserialize,
      );

      // Assert
      expect(parsed!.list, isEmpty);
      expect(parsed.notFound, containsAll({Id('X1'), Id('X2')}));
    });

    test('should return empty results when server returns empty list',
        () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": "state",
            "methodResponses": [
              [
                "Label/get",
                {
                  "accountId": accountId.id.value,
                  "state": "s1",
                  "list": [],
                  "notFound": []
                },
                "c0"
              ]
            ]
          },
        ),
        data: buildRequestPayload(ids: ['A']),
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = GetLabelMethod(accountId)..addIds({Id('A')});
      final invocation = builder.invocation(method);

      // Act
      final response = await (builder..usings(method.requiredCapabilities))
          .build()
          .execute();

      final parsed = response.parse<GetLabelResponse>(
        invocation.methodCallId,
        GetLabelResponse.deserialize,
      );

      // Assert
      expect(parsed!.list, isEmpty);
      expect(parsed.notFound, isEmpty);
    });

    test('should throw DioError when server returns 500', () async {
      // Arrange
      final dio = createDio();
      final adapter = DioAdapter(dio: dio);

      adapter.onPost(
        '',
        (server) => server.reply(500, {}),
        data: buildRequestPayload(ids: ['A']),
        headers: createJMAPHeader(),
      );

      final builder = createBuilder(dio);
      final method = GetLabelMethod(accountId)..addIds({Id('A')});

      // Act
      final future =
          (builder..usings(method.requiredCapabilities)).build().execute();

      // Assert
      expect(future, throwsA(isA<DioError>()));
    });
  });
}
