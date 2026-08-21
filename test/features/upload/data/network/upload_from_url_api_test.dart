import 'dart:io';

import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_from_url_api.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

import '../../../../fixtures/account_fixtures.dart';
import 'upload_from_url_api_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DioClient>()])
void main() {
  group('UploadFromUrlApi::uploadFromUrl', () {
    late MockDioClient dioClient;
    late UploadFromUrlApi uploadFromUrlApi;

    final accountId = AccountFixtures.aliceAccountId;

    final uploadUri = Uri.parse('https://mail.example.com/upload-from-url/${AccountFixtures.aliceAccountId.id.value}');
    final downloadLink = Uri.parse('https://drive.example.com/secret-token/file.pdf');
    const documentName = 'report.pdf';
    const mimeType = 'application/pdf';
    final request = UploadFromUrlRequest(
      accountId: accountId,
      uploadUri: uploadUri,
      attachmentUrl: downloadLink,
      name: documentName,
      mimeType: mimeType,
    );

    setUp(() {
      dioClient = MockDioClient();
      uploadFromUrlApi = UploadFromUrlApi(dioClient);
    });

    test('should return UploadResponse when DioClient returns the standard upload contract', () async {
      when(dioClient.post(
        any,
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => {
        'accountId': accountId.id.value,
        'blobId': 'blob-id-123',
        'type': mimeType,
        'size': 2048,
      });

      final result = await uploadFromUrlApi.uploadFromUrl(request);

      expect(result.accountId, accountId);
      expect(result.blobId.value, 'blob-id-123');
      expect(result.size, 2048);
    });

    test('should call DioClient.post on the upload url advertised by the capability', () async {
      when(dioClient.post(
        any,
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => {
        'accountId': accountId.id.value,
        'blobId': 'blob-id-123',
        'type': mimeType,
        'size': 2048,
      });

      await uploadFromUrlApi.uploadFromUrl(request);

      verify(dioClient.post(
        uploadUri.toString(),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).called(1);
    });

    for (final statusCode in [400, 401, 403, 413, 429, 500, 502, 504]) {
      test('should propagate the unmapped DioException for status $statusCode', () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: uploadUri.toString()),
          response: Response(
            requestOptions: RequestOptions(path: uploadUri.toString()),
            statusCode: statusCode,
          ),
        );
        when(dioClient.post(
          any,
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        )).thenThrow(dioException);

        expect(
          uploadFromUrlApi.uploadFromUrl(request),
          throwsA(same(dioException)),
        );
      });
    }

    test('should send the url/type as headers with an empty body, and forward the cancelToken', () async {
      final cancelToken = CancelToken();
      final requestWithCancelToken = UploadFromUrlRequest(
        accountId: accountId,
        uploadUri: uploadUri,
        attachmentUrl: downloadLink,
        name: documentName,
        mimeType: mimeType,
        cancelToken: cancelToken,
      );
      when(dioClient.post(
        any,
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => {
        'accountId': accountId.id.value,
        'blobId': 'blob-id-123',
        'type': mimeType,
        'size': 2048,
      });

      await uploadFromUrlApi.uploadFromUrl(requestWithCancelToken);

      final captured = verify(dioClient.post(
        uploadUri.toString(),
        options: captureAnyNamed('options'),
        cancelToken: captureAnyNamed('cancelToken'),
      )).captured;
      final options = captured[0] as Options;
      expect(options.headers, {
        HttpHeaders.contentTypeHeader: mimeType,
        HttpHeaders.contentLocationHeader: downloadLink.toString(),
      });
      expect(captured[1], same(cancelToken));
    });

    test('should never include the downloadLink value as the POST path', () async {
      when(dioClient.post(
        any,
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => {
        'accountId': accountId.id.value,
        'blobId': 'blob-id-123',
        'type': mimeType,
        'size': 2048,
      });

      await uploadFromUrlApi.uploadFromUrl(request);

      final capturedPath = verify(dioClient.post(
        captureAny,
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).captured.single as String;
      expect(capturedPath.contains(downloadLink.toString()), isFalse);
    });
  });
}
