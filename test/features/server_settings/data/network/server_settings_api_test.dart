import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:server_settings/server_settings/server_settings_id.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/server_settings/data/network/server_settings_api.dart';
import 'package:tmail_ui_user/features/server_settings/domain/exceptions/server_settings_exception.dart';

import '../../../../fixtures/session_fixtures.dart';

void main() {
  final newServerSettings = TMailServerSettings(
    id: ServerSettingsIdExtension.serverSettingsIdSingleton,
    settings: TMailServerSettingOptions(alwaysReadReceipts: true),
  );
  group('server settings api', () {
    test('should throw CanNotUpdateServerSettingsException '
    'when module throw exception on parse on update settings', () async {
      // arrange
      final baseOption = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": "abcdefghij",
            "methodResponses": [
              [
                "error",
                {
                    "type": "invalidArguments",
                    "description": "'/accountId' property is not valid: Predicate failed: '' contains some invalid characters. Should be [#a-zA-Z0-9-_] and no longer than 255 chars."
                },
                "c0"
              ],
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
                "c1"
              ]
            ]
          },
        ),
        data: {
          "using": [
            "urn:ietf:params:jmap:core",
            "com:linagora:params:jmap:settings"
          ],
          "methodCalls": [
            [
              "Settings/set",
              {
                "accountId": "123",
                "update": {
                  "singleton": {
                    "id": "singleton",
                    "settings": {"read.receipts.always": "true"}
                  }
                }
              },
              "c0"
            ],
            [
              "Settings/get",
              {
                "accountId": "123",
                "ids": ["singleton"]
              },
              "c1"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
        },
      );

      final httpClient = HttpClient(dio);
      final serverSettingsAPI = ServerSettingsAPI(httpClient);
      final session = SessionFixtures.aliceSession;
      final accountId = AccountId(Id('123'));

      // assert
      expect(
        serverSettingsAPI.updateServerSettings(
          session,
          accountId, 
          newServerSettings),
        throwsA(isA<CanNotUpdateServerSettingsException>()));
    });
  });
}