import 'package:contact/contact/autocomplete/autocomplete_tmail_contact_method.dart';
import 'package:contact/contact/autocomplete/autocomplete_tmail_contact_response.dart';
import 'package:contact/contact/model/contact_filter.dart';
import 'package:contact/contact/model/tmail_contact.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

void main() {
  group('test to json autocomplete_tmail_contact method', () {
    final contact1 = TMailContact(
        '2',
         '',
         '',
        'marie@otherdomain.tld'
    );

    final contact2 = TMailContact(
        '4',
        'Marie',
        'Dupond',
        'mdupond@linagora.com'
    );

    test('autocomplete_tmail_contact method and response parsing', () async {
      final baseOption  = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)
        ..options.baseUrl = 'http://domain.com';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
          '/jmap',
          (server) => server.reply(200, {
                "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
                "methodResponses": [
                  [
                    "TMailContact/autocomplete",
                    {
                      "accountId":
                          "29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6",
                      "list": [
                        {
                          "id": "2",
                          "firstname": "",
                          "surname": "",
                          "emailAddress": "marie@otherdomain.tld"
                        },
                        {
                          "id": "4",
                          "firstname": "Marie",
                          "surname": "Dupond",
                          "emailAddress": "mdupond@linagora.com"
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
              "com:linagora:params:jmap:contact:autocomplete"
            ],
            "methodCalls": [
              [
                "TMailContact/autocomplete",
                {
                  "accountId":
                      "29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6",
                  "filter": {
                    "text": "marie"
                  }
                },
                "c0"
              ]
            ]
          },
          headers: {
            "accept": "application/json;jmapVersion=rfc-8621",
            "content-type": "application/json; charset=utf-8",
            "content-length": 245
          });

      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();
      final requestBuilder = JmapRequestBuilder(httpClient, processingInvocation);
      final accountId = AccountId(Id('29883977c13473ae7cb7678ef767cbfbaffc8a44a6e463d971d23a65c1dc4af6'));

      final autoCompleteMethod = AutoCompleteTMailContactMethod(
          accountId,
          ContactFilter('marie'));
      
      final autoCompleteInvocation = requestBuilder.invocation(autoCompleteMethod);
      final response = await (requestBuilder
            ..usings(autoCompleteMethod.requiredCapabilities))
          .build()
          .execute();

      final result = response.parse<AutoCompleteTMailContactResponse>(
          autoCompleteInvocation.methodCallId,
          AutoCompleteTMailContactResponse.deserialize);

      expect(result?.list.length, equals(2));
      expect(result?.list, containsAll({contact1, contact2}));
    });
  });
}