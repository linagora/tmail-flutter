import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/set/set_public_asset_method.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/set/set_public_asset_response.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/public_asset/data/network/public_asset_api.dart';
import 'package:tmail_ui_user/features/public_asset/domain/exceptions/public_asset_exceptions.dart';
import 'package:uuid/uuid.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/session_fixtures.dart';
import 'public_asset_api_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Uuid>()])
void main() {
  final baseOption = BaseOptions(method: 'POST');
  final dio = Dio(baseOption)..options.baseUrl = 'http://domain.com/jmap';
  final dioAdapter = DioAdapter(dio: dio);
  final dioAdapterHeaders = {"accept": "application/json;jmapVersion=rfc-8621"};
  final httpClient = HttpClient(dio);
  final processingInvocation = ProcessingInvocation();
  final requestBuilder = JmapRequestBuilder(httpClient, processingInvocation);
  final identityId = IdentityId(Id('some-identity-id'));
  final methodCallId = MethodCallId('c0');
  final publicAssetToBeDereferenced = PublicAsset(
    id: Id('abc123'),
    blobId: Id('def456'),
    size: 123,
    contentType: 'image/jpeg',
    publicURI: 'http://domain.com/public/abc123',
    identityIds: {identityId: true}
  );
  final publicAssetToBeReferenced = PublicAsset(
    id: Id('ghi789'),
    blobId: Id('jkl012'),
    size: 456,
    contentType: 'image/png',
    publicURI: 'http://domain.com/public/ghi789',
    identityIds: {}
  );

  final publicAssetApi = PublicAssetApi(httpClient, MockUuid());
  final accountId = AccountFixtures.aliceAccountId;
  final session = SessionFixtures.aliceSession;
  final mapPublicAssetIdToUpdatingIdentityIds = {
    publicAssetToBeDereferenced.id!: {identityId: null},
    publicAssetToBeReferenced.id!: {identityId: true}
  };
  final dereferencedUpdateObject = PatchObject({
    '${PatchObject.identityIdsProperty}/${identityId.id.value}': null,
  });
  final referencedUpdateObject = PatchObject({
    '${PatchObject.identityIdsProperty}/${identityId.id.value}': true,
  });
  final method = SetPublicAssetMethod(accountId)
    ..addUpdates({
      publicAssetToBeDereferenced.id!: dereferencedUpdateObject,
      publicAssetToBeReferenced.id!: referencedUpdateObject
    });
  
  group('public asset api test:', () {
    test(
      'should complete without exception '
      'when server returns updated public asset ids',
    () async {
      // arrange
      final invocation = requestBuilder.invocation(
        method,
        methodCallId: methodCallId);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "abcdefghij",
          "methodResponses": [[
            method.methodName.value,
            {
              "accountId": accountId.id.value,
              "newState": 'some-state',
              "updated": {
                publicAssetToBeDereferenced.id?.value: null,
                publicAssetToBeReferenced.id?.value: null
              },
            },
            methodCallId.value
          ]]
        }),
        data: {
          "using": method.requiredCapabilities
            .map((capability) => capability.value.toString())
            .toList(),
          "methodCalls": [
            [
              method.methodName.value,
              {
                "accountId": accountId.id.value,
                "update": {
                  publicAssetToBeDereferenced.id?.value: dereferencedUpdateObject.toJson(),
                  publicAssetToBeReferenced.id?.value: referencedUpdateObject.toJson(),
                },
              },
              methodCallId.value
            ],
          ]
        },
        headers: dioAdapterHeaders,
      );
      
      // act
      final response = (await (requestBuilder..usings(method.requiredCapabilities))
        .build()
        .execute())
          .parse<SetPublicAssetResponse>(
            invocation.methodCallId,
            SetPublicAssetResponse.deserialize);
      
      // assert
      expect(
        response?.updated,
        equals({
          publicAssetToBeDereferenced.id: null,
          publicAssetToBeReferenced.id: null
        })
      );
      await expectLater(
        publicAssetApi.partialUpdatePublicAssets(
          session,
          accountId,
          mapPublicAssetIdToUpdatingIdentityIds: mapPublicAssetIdToUpdatingIdentityIds),
        completes);
    });

    test(
      'should complete with exception '
      'when server returns notUpdated public asset ids',
    () async {
      // arrange
      const errorDescription = 'Invalid identity';
      final invocation = requestBuilder.invocation(
        method,
        methodCallId: methodCallId);
      dioAdapter.onPost(
        '',
        (server) => server.reply(200, {
          "sessionState": "abcdefghij",
          "methodResponses": [[
            method.methodName.value,
            {
              "accountId": accountId.id.value,
              "newState": 'some-state',
              "notUpdated": {
                publicAssetToBeDereferenced.id?.value: {
                  "type": "invalidArguments",
                  "description": errorDescription
                },
                publicAssetToBeReferenced.id?.value: {
                  "type": "invalidArguments",
                  "description": errorDescription
                }
              }
            },
            methodCallId.value
          ]]
        }),
        data: {
          "using": method.requiredCapabilities
            .map((capability) => capability.value.toString())
            .toList(),
          "methodCalls": [
            [
              method.methodName.value,
              {
                "accountId": accountId.id.value,
                "update": {
                  publicAssetToBeDereferenced.id?.value: dereferencedUpdateObject.toJson(),
                  publicAssetToBeReferenced.id?.value: referencedUpdateObject.toJson(),
                },
              },
              methodCallId.value
            ],
          ]
        },
        headers: dioAdapterHeaders,
      );
      
      // act
      final response = (await (requestBuilder..usings(method.requiredCapabilities))
        .build()
        .execute())
          .parse<SetPublicAssetResponse>(
            invocation.methodCallId,
            SetPublicAssetResponse.deserialize);
      
      // assert
      expect(
        response?.notUpdated?[publicAssetToBeDereferenced.id],
        SetError(SetError.invalidArguments, description: errorDescription),
      );
      expect(
        response?.notUpdated?[publicAssetToBeReferenced.id],
        SetError(SetError.invalidArguments, description: errorDescription),
      );
      await expectLater(
        publicAssetApi.partialUpdatePublicAssets(
          session,
          accountId,
          mapPublicAssetIdToUpdatingIdentityIds: mapPublicAssetIdToUpdatingIdentityIds),
        throwsA(isA<CannotUpdatePublicAssetException>()));
    });
  });
}