import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forward/forward/forward_id.dart';
import 'package:forward/forward/get/get_forward_method.dart';
import 'package:forward/forward/get/get_forward_response.dart';
import 'package:forward/forward/set/set_forward_method.dart';
import 'package:forward/forward/set/set_forward_response.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';

void main() {
  group('test to json set forward method', () {
    final expectedUpdated = TMailForward(
      id: ForwardIdSingleton.forwardIdSingleton,
      localCopy: true,
      forwards: {'dab@domain.com', 'vuda@gmail.com'}
    );

    test('set forward method and response parsing', () async {
      final baseOption  = BaseOptions(method: 'POST');
      final dio = Dio(baseOption)
        ..options.baseUrl = 'http://domain.com/jmap';
      final dioAdapter = DioAdapter(dio: dio);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
          "methodResponses": [
            [
              "Forward/set",
              {
                "accountId": "0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555",
                "newState": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
                "updated": {
                  "singleton": {}
                }
              },
              "c0"
            ],
            [
              "Forward/get",
              {
                "accountId": "0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555",
                "notFound": [],
                "state": "2c9f1b12-b35a-43e6-9af2-0106fb53a943",
                "list": [
                  {
                    "id": "singleton",
                    "localCopy": true,
                    "forwards": [
                      "dab@domain.com",
                      "vuda@gmail.com"
                    ]
                  }
                ]
              },
              "c1"
            ]
          ]
        }),
        data: {
          "using": [
            "urn:ietf:params:jmap:core",
            "com:linagora:params:jmap:forward"
          ],
          "methodCalls": [
            [
              "Forward/set",
              {
                "accountId": "0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555",
                "update": {
                  "singleton": {
                    "id": "singleton",
                    "localCopy": true,
                    "forwards": [
                      "dab@domain.com",
                      "vuda@gmail.com"
                    ]
                  }
                }
              },
              "c0"
            ],
            [
              "Forward/get",
              {
                "accountId": "0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555",
                "ids": [
                  "singleton"
                ]
              },
              "c1"
            ]
          ]
        },
        headers: {
          "accept": "application/json;jmapVersion=rfc-8621",
          "content-length": 765
        }
      );

      final accountId = AccountId(Id('0d14dbabe6482aff5cbf922e04cef51a40b4eabccbe12d28fe27c97038752555'));
      final httpClient = HttpClient(dio);
      final processingInvocation = ProcessingInvocation();

      final setForwardMethod = SetForwardMethod(accountId)
        ..addUpdatesSingleton({
          ForwardIdSingleton.forwardIdSingleton.id : TMailForward(
              id: ForwardIdSingleton.forwardIdSingleton,
              localCopy: true,
              forwards: {'dab@domain.com', 'vuda@gmail.com'}
          )
        });

      final requestBuilder = JmapRequestBuilder(httpClient, processingInvocation)
        ..invocation(setForwardMethod);

      final getForwardMethod = GetForwardMethod(accountId)
        ..addIds({ForwardIdSingleton.forwardIdSingleton.id});
      final getForwardInvocation = requestBuilder.invocation(getForwardMethod);

      final response = await (requestBuilder
          ..usings(setForwardMethod.requiredCapabilities))
        .build()
        .execute();

      final getForwardResponse = response.parse<GetForwardResponse>(
          getForwardInvocation.methodCallId,
          GetForwardResponse.deserialize);

      expect(getForwardResponse!.list.length, equals(1));
      expect(getForwardResponse.list, containsAll({expectedUpdated}));
    });
  });

  group('set forward method test:', () {
    const String baseUrl = 'http://domain.com/jmap';

    late final Dio dio;
    late final DioAdapter dioAdapter;

    final methodCallId = MethodCallId('c0');
    final bobAccountId = AccountId(Id('bob'));
    final sessionState = State('sessionState');
    final newState = State('newState');
    final tmailForward = TMailForward(
      id: ForwardIdSingleton.forwardIdSingleton,
      localCopy: true,
      forwards: {'targetA@domain.org', 'targetB@domain.org'},
    );

    setUpAll(() {
      dio = Dio(BaseOptions(method: 'POST'))..options.baseUrl = baseUrl;
      dioAdapter = DioAdapter(dio: dio);
    });

    test('Should fail when wrong account id', () async {
      // Arrange
      final unknownAccountId = AccountId(Id('unknownAccountId'));
      final setForwardMethod = SetForwardMethod(unknownAccountId)
        ..addUpdatesSingleton({
          tmailForward.id!.id : tmailForward
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "error",
                {
                  "type": "accountNotFound",
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": setForwardMethod.requiredCapabilities
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": unknownAccountId.id.value,
                "update": {tmailForward.id!.id.value: tmailForward.toJson()}
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(setForwardMethod.requiredCapabilities))
          .build()
          .execute();

      // Assert
      expect(
        () => responseObject.parse<SetForwardResponse>(
          invocation.methodCallId,
          SetForwardResponse.deserialize,
        ),
        throwsA(ErrorMethodResponseException(AccountNotFoundMethodResponse())),
      );
    });

    test('Should return unknown method when missing one capability', () async {
      // Arrange
      final listCapabilitiesUsed = {CapabilityIdentifier.jmapCore};
      final setForwardMethod = SetForwardMethod(bobAccountId)
        ..addUpdatesSingleton({
          tmailForward.id!.id : tmailForward
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "error",
                {
                  "type": "unknownMethod",
                  "description":
                      "Missing capability(ies): com:linagora:params:jmap:forward"
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": listCapabilitiesUsed
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": bobAccountId.id.value,
                "update": {tmailForward.id!.id.value: tmailForward.toJson()}
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(listCapabilitiesUsed))
          .build()
          .execute();

      // Assert
      expect(
        () => responseObject.parse<SetForwardResponse>(
          invocation.methodCallId,
          SetForwardResponse.deserialize,
        ),
        throwsA(ErrorMethodResponseException(UnknownMethodResponse(
          description:
              'Missing capability(ies): com:linagora:params:jmap:forward',
        ))),
      );
    });

    test('Should return unknown method when missing all capabilities',
        () async {
      // Arrange
      final listCapabilitiesUsed = <CapabilityIdentifier>{};
      final setForwardMethod = SetForwardMethod(bobAccountId)
        ..addUpdatesSingleton({
          tmailForward.id!.id : tmailForward
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "error",
                {
                  "type": "unknownMethod",
                  "description":
                      "Missing capability(ies): urn:ietf:params:jmap:core, com:linagora:params:jmap:forward"
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": listCapabilitiesUsed
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": bobAccountId.id.value,
                "update": {tmailForward.id!.id.value: tmailForward.toJson()}
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(listCapabilitiesUsed))
          .build()
          .execute();

      // Assert
      expect(
        () => responseObject.parse<SetForwardResponse>(
          invocation.methodCallId,
          SetForwardResponse.deserialize,
        ),
        throwsA(ErrorMethodResponseException(UnknownMethodResponse(
          description:
              'Missing capability(ies): urn:ietf:params:jmap:core, com:linagora:params:jmap:forward',
        ))),
      );
    });

    test('Should return success', () async {
      // Arrange
      final setForwardMethod = SetForwardMethod(bobAccountId)
        ..addUpdatesSingleton({
          tmailForward.id!.id : tmailForward
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Forward/set",
                {
                  "accountId": bobAccountId.id.value,
                  "newState": newState.value,
                  "updated": {tmailForward.id!.id.value: {}}
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": setForwardMethod.requiredCapabilities
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": bobAccountId.id.value,
                "update": {tmailForward.id!.id.value: tmailForward.toJson()}
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(setForwardMethod.requiredCapabilities))
          .build()
          .execute();

      final setForwardResponse = responseObject.parse<SetForwardResponse>(
        invocation.methodCallId,
        SetForwardResponse.deserialize,
      );

      // Assert
      expect(
        setForwardResponse?.updated,
        isNotEmpty,
      );
      expect(
        setForwardResponse?.notUpdated,
        isNull,
      );
      expect(
        setForwardResponse?.notCreated,
        isNull,
      );
      expect(
        setForwardResponse?.notDestroyed,
        isNull,
      );
    });

    test('Should fail when missing forwards', () async {
      // Arrange
      final setForwardMethod = SetForwardMethod(bobAccountId)
        ..addUpdatesSingleton({
          tmailForward.id!.id : TMailForward(
            localCopy: true,
          )
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Forward/set",
                {
                  "accountId": bobAccountId.id.value,
                  "newState": newState.value,
                  "notUpdated": {
                    tmailForward.id!.id.value: {
                      "type": "invalidArguments",
                      "description": "Missing '/forwards' property"
                    }
                  }
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": setForwardMethod.requiredCapabilities
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": bobAccountId.id.value,
                "update": {
                  tmailForward.id!.id.value: {"localCopy": true}
                }
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(setForwardMethod.requiredCapabilities))
          .build()
          .execute();

      final setForwardResponse = responseObject.parse<SetForwardResponse>(
        invocation.methodCallId,
        SetForwardResponse.deserialize,
      );

      // Assert
      expect(
        setForwardResponse?.updated,
        isNull,
      );
      expect(
        setForwardResponse?.notUpdated?.values.firstOrNull?.type,
        SetError.invalidArguments,
      );
      expect(
        setForwardResponse?.notUpdated?.values.firstOrNull?.description,
        'Missing \'/forwards\' property',
      );
    });

    test('Should fail when missing localCopy', () async {
      // Arrange
      final setForwardMethod = SetForwardMethod(bobAccountId)
        ..addUpdatesSingleton({
          tmailForward.id!.id : TMailForward(
            forwards: {},
          )
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Forward/set",
                {
                  "accountId": bobAccountId.id.value,
                  "newState": newState.value,
                  "notUpdated": {
                    tmailForward.id!.id.value: {
                      "type": "invalidArguments",
                      "description": "Missing '/localCopy' property"
                    }
                  }
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": setForwardMethod.requiredCapabilities
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": bobAccountId.id.value,
                "update": {
                  tmailForward.id!.id.value: {"forwards": []}
                }
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(setForwardMethod.requiredCapabilities))
          .build()
          .execute();

      final setForwardResponse = responseObject.parse<SetForwardResponse>(
        invocation.methodCallId,
        SetForwardResponse.deserialize,
      );

      // Assert
      expect(
        setForwardResponse?.updated,
        isNull,
      );
      expect(
        setForwardResponse?.notUpdated?.values.firstOrNull?.type,
        SetError.invalidArguments,
      );
      expect(
        setForwardResponse?.notUpdated?.values.firstOrNull?.description,
        'Missing \'/localCopy\' property',
      );
    });

    test('Should fail when invalid key', () async {
      // Arrange
      final setForwardMethod = SetForwardMethod(bobAccountId)
        ..addUpdatesSingleton({
          Id('invalidKey'): tmailForward
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Forward/set",
                {
                  "accountId": bobAccountId.id.value,
                  "newState": newState.value,
                  "notUpdated": {
                    "invalidKey": {
                      "type": "invalidArguments",
                      "description": "id invalidKey must be singleton"
                    }
                  }
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": setForwardMethod.requiredCapabilities
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": bobAccountId.id.value,
                "update": {
                  "invalidKey": tmailForward.toJson(),
                }
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(setForwardMethod.requiredCapabilities))
          .build()
          .execute();

      final setForwardResponse = responseObject.parse<SetForwardResponse>(
        invocation.methodCallId,
        SetForwardResponse.deserialize,
      );

      // Assert
      expect(
        setForwardResponse?.updated,
        isNull,
      );
      expect(
        setForwardResponse?.notUpdated?.values.firstOrNull?.type,
        SetError.invalidArguments,
      );
      expect(
        setForwardResponse?.notUpdated?.values.firstOrNull?.description,
        'id invalidKey must be singleton',
      );
    });

    test('Should fail when invalid forwards', () async {
      // Arrange
      final setForwardMethod = SetForwardMethod(bobAccountId)
        ..addUpdatesSingleton({
          tmailForward.id!.id: tmailForward.copyWith(
            forwards: {"123\$#%\$#invalid"}
          )
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Forward/set",
                {
                  "accountId": bobAccountId.id.value,
                  "newState": newState.value,
                  "notUpdated": {
                    tmailForward.id!.id.value: {
                      "type": "invalidArguments",
                      "description":
                          "'/forwards(0)' property is not valid: Invalid mailAddress: Out of data at position 1 in '123\$\$#%\$\$#invalid'"
                    }
                  }
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": setForwardMethod.requiredCapabilities
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": bobAccountId.id.value,
                "update": {
                  tmailForward.id!.id.value: tmailForward.copyWith(
                    forwards: {"123\$#%\$#invalid"}
                  ).toJson(),
                }
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(setForwardMethod.requiredCapabilities))
          .build()
          .execute();

      final setForwardResponse = responseObject.parse<SetForwardResponse>(
        invocation.methodCallId,
        SetForwardResponse.deserialize,
      );

      // Assert
      expect(
        setForwardResponse?.updated,
        isNull,
      );
      expect(
        setForwardResponse?.notUpdated?.values.firstOrNull?.type,
        SetError.invalidArguments,
      );
      expect(
        setForwardResponse?.notUpdated?.values.firstOrNull?.description,
        '\'/forwards(0)\' property is not valid: Invalid mailAddress: Out of data at position 1 in \'123\$\$#%\$\$#invalid\'',
      );
    });

    test('Should noop when empty map', () async {
      // Arrange
      final setForwardMethod = SetForwardMethod(bobAccountId)
        ..addUpdatesSingleton({});
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "Forward/set",
                {
                  "accountId": bobAccountId.id.value,
                  "newState": newState.value
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": setForwardMethod.requiredCapabilities
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": bobAccountId.id.value,
                "update": {},
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(setForwardMethod.requiredCapabilities))
          .build()
          .execute();

      final setForwardResponse = responseObject.parse<SetForwardResponse>(
        invocation.methodCallId,
        SetForwardResponse.deserialize,
      );

      // Assert
      expect(
        setForwardResponse?.updated,
        isNull,
      );
      expect(
        setForwardResponse?.notUpdated,
        isNull,
      );
    });

    test('Should reject from delegated account', () async {
      // Arrange
      final aliceAccountId = AccountId(Id('Alice'));
      final setForwardMethod = SetForwardMethod(aliceAccountId)
        ..addUpdatesSingleton({
          tmailForward.id!.id: tmailForward,
        });
      final requestBuilder = JmapRequestBuilder(
        HttpClient(dio),
        ProcessingInvocation(),
      );
      final invocation = requestBuilder.invocation(
        setForwardMethod,
        methodCallId: methodCallId,
      );
      dioAdapter.onPost(
        '',
        (server) => server.reply(
          200,
          {
            "sessionState": sessionState.value,
            "methodResponses": [
              [
                "error",
                {
                  "type": "forbidden",
                  "description":
                      "Access to other accounts settings is forbidden"
                },
                methodCallId.value,
              ],
            ],
          },
        ),
        data: {
          "using": setForwardMethod.requiredCapabilities
              .map((capability) => capability.value.toString())
              .toList(),
          "methodCalls": [
            [
              setForwardMethod.methodName.value,
              {
                "accountId": aliceAccountId.id.value,
                "update": {
                  tmailForward.id!.id.value: tmailForward.toJson(),
                },
              },
              methodCallId.value,
            ]
          ]
        },
      );

      // Act
      final responseObject = await (requestBuilder
            ..usings(setForwardMethod.requiredCapabilities))
          .build()
          .execute();

      // Assert
      expect(
        () => responseObject.parse<SetForwardResponse>(
          invocation.methodCallId,
          SetForwardResponse.deserialize,
        ),
        throwsA(ErrorMethodResponseException(ForbiddenMethodResponse(
            description: 'Access to other accounts settings is forbidden'))),
      );
    });
  });
}