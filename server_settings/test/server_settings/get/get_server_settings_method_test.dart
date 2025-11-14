import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:server_settings/server_settings/get/get_server_settings_method.dart';
import 'package:server_settings/server_settings/get/get_server_settings_response.dart';
import 'package:server_settings/server_settings/server_settings_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';

void main() {
  final expectedResult = TMailServerSettings(
    id: ServerSettingsIdExtension.serverSettingsIdSingleton,
    settings: TMailServerSettingOptions(alwaysReadReceipts: true),
  );

  group('get server settings method', () {
    test('should return expected result', () async {
      // arrange
      final baseOption = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "abcdefghij",
          "methodResponses": [
            [
              "Settings/get",
              {
                "accountId": "123",
                "notFound": [],
                "state": "1",
                "list": [
                  {
                    "id": "singleton",
                    "settings": {"read.receipts.always": "true"}
                  }
                ]
              },
              "c0"
            ]
          ]
        }),
        data: {
          "using": [
            "urn:ietf:params:jmap:core",
            "com:linagora:params:jmap:settings"
          ],
          "methodCalls": [
            [
              "Settings/get",
              {
                "accountId": "123",
                "ids": ["singleton"]
              },
              "c0"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
        },
      );

      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();
      final requestBuilder =
          JmapRequestBuilder(httpClient, processingInvocation);
      final accountId = AccountId(Id('123'));

      final getServerSettingsMethod = GetServerSettingsMethod(accountId)
        ..addIds({ServerSettingsIdExtension.serverSettingsIdSingleton.id});
      final getServerSettingsInvocation = requestBuilder.invocation(getServerSettingsMethod);

      // act
      final response = await (requestBuilder
      ..usings(getServerSettingsMethod.requiredCapabilities))
        .build()
        .execute();

      final resultList = response.parse<GetServerSettingsResponse>(
          getServerSettingsInvocation.methodCallId,
          GetServerSettingsResponse.deserialize);

      // assert
      expect(resultList?.list.length, equals(1));
      expect(resultList?.list, containsAll({expectedResult}));
    });
  });
}
