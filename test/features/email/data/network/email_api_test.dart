import 'dart:io';

import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/data/network/download/download_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/http/http_client.dart' as jmap;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/data/network/email_api.dart';
import 'package:tmail_ui_user/features/email/data/utils/download_utils.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

import 'email_api_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<DioClient>(),
  MockSpec<jmap.HttpClient>(),
  MockSpec<DownloadManager>(),
  MockSpec<Uuid>(),
  MockSpec<DownloadUtils>(),
])
void main() {
  late MockDioClient dioClient;
  late MockDownloadManager downloadManager;
  late MockUuid uuid;
  late MockHttpClient httpClient;
  late MockDownloadUtils downloadUtils;
  late EmailAPI emailAPI;

  final accountId = AccountId(Id('abc123'));
  const baseDownloadUrl = 'https://example.com/download/{accountId}/{blobId}?type={type}&name={name}';
  final blobId = Id('xyz123');

  setUp(() {
    dioClient = MockDioClient();
    downloadManager = MockDownloadManager();
    uuid = MockUuid();
    httpClient = MockHttpClient();
    downloadUtils = MockDownloadUtils();
    emailAPI = EmailAPI(
      httpClient,
      downloadManager,
      dioClient,
      uuid,
      downloadUtils
    );
  });

  group('downloadMessageAsEML method test', () {
    test('should call createAnchorElementDownloadFileWeb when download email as EML file success and return Uint8List', () async {
      final accountRequestFixture = AccountRequest(
        authenticationType: AuthenticationType.oidc,
        token: TokenOIDC(
          'accessToken',
          TokenId('token-id'),
          'refreshToken'
        ),
      );
      const subjectEmailFixture = 'hello';
      const fileNameFixture = '$subjectEmailFixture.eml';
      final downloadUrlFixture = 'https://example.com/download/${accountId.asString}/${blobId.value}?type=${Constant.octetStreamMimeType}&name=$fileNameFixture';
      final responseFixture = Uint8List.fromList([1, 2, 3, 4]);

      when(
        downloadUtils.createEMLFileName(subjectEmailFixture)
      ).thenAnswer((_) => fileNameFixture);

      when(
        downloadUtils.getEMLDownloadUrl(
          baseDownloadUrl: baseDownloadUrl,
          accountId: accountId,
          blobId: blobId,
          subject: subjectEmailFixture
        )
      ).thenAnswer((_) => downloadUrlFixture);

      when(dioClient.getHeaders()).thenAnswer((_) => {});

      when(
        dioClient.get(
          any,
          options: anyNamed('options'),
        )
      ).thenAnswer((_) async => responseFixture);

      await emailAPI.downloadMessageAsEML(
        accountId,
        baseDownloadUrl,
        accountRequestFixture,
        blobId,
        subjectEmailFixture);

      verify(downloadUtils.createEMLFileName(subjectEmailFixture)).called(1);

      verify(
        downloadUtils.getEMLDownloadUrl(
          baseDownloadUrl: baseDownloadUrl,
          accountId: accountId,
          blobId: blobId,
          subject: subjectEmailFixture,
        )
      ).called(1);

      verify(dioClient.getHeaders()).called(1);

      verify(
        dioClient.get(
          downloadUrlFixture,
          options: argThat(
            isA<Options>()
              .having((o) => o.headers?[HttpHeaders.authorizationHeader], 'authorization header', accountRequestFixture.bearerToken)
              .having((o) => o.headers?[HttpHeaders.acceptHeader], 'accept header', DioClient.jmapHeader)
              .having((o) => o.responseType, 'responseType', ResponseType.bytes),
            named: 'options',
        ),
      )).called(1);

      verify(
        downloadManager.createAnchorElementDownloadFileWeb(
          responseFixture,
          fileNameFixture
        )
      ).called(1);
    });

    test('should throw an NotFoundByteFileDownloadedException exception if response is not Uint8List', () async {
      final accountRequestFixture = AccountRequest(
        authenticationType: AuthenticationType.oidc,
        token: TokenOIDC(
            'accessToken',
            TokenId('token-id'),
            'refreshToken'
        ),
      );
      const subjectEmailFixture = 'hello';
      const fileNameFixture = '$subjectEmailFixture.eml';
      final downloadUrlFixture = 'https://example.com/download/${accountId.asString}/${blobId.value}?type=${Constant.octetStreamMimeType}&name=$fileNameFixture';

      when(
        downloadUtils.createEMLFileName(subjectEmailFixture)
      ).thenAnswer((_) => fileNameFixture);

      when(
        downloadUtils.getEMLDownloadUrl(
          baseDownloadUrl: baseDownloadUrl,
          accountId: accountId,
          blobId: blobId,
          subject: subjectEmailFixture
        )
      ).thenAnswer((_) => downloadUrlFixture);

      when(dioClient.getHeaders()).thenAnswer((_) => {});

      when(
        dioClient.get(
          any,
          options: anyNamed('options'),
        )
      ).thenAnswer((_) async => 'Unexpected response');

      expect(
        () async => await emailAPI.downloadMessageAsEML(
          accountId,
          baseDownloadUrl,
          accountRequestFixture,
          blobId,
          subjectEmailFixture
        ),
        throwsA(isA<NotFoundByteFileDownloadedException>()),
      );

      verify(downloadUtils.createEMLFileName(subjectEmailFixture)).called(1);

      verify(
        downloadUtils.getEMLDownloadUrl(
          baseDownloadUrl: baseDownloadUrl,
          accountId: accountId,
          blobId: blobId,
          subject: subjectEmailFixture,
        )
      ).called(1);

      verify(dioClient.getHeaders()).called(1);

      verify(
        dioClient.get(
          downloadUrlFixture,
          options: argThat(
            isA<Options>()
              .having((o) => o.headers?[HttpHeaders.authorizationHeader], 'authorization header', accountRequestFixture.bearerToken)
              .having((o) => o.headers?[HttpHeaders.acceptHeader], 'accept header', DioClient.jmapHeader)
              .having((o) => o.responseType, 'responseType', ResponseType.bytes),
            named: 'options',
          ),
        )
      ).called(1);
    });
  });
}
