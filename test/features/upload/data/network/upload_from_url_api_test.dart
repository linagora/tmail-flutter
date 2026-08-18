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
    final downloadLink = Uri.parse('https://drive.example.com/secret-token/file.pdf');
    const documentName = 'report.pdf';
    const mimeType = 'application/pdf';
    final request = UploadFromUrlRequest(
      accountId: accountId,
      downloadLink: downloadLink,
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
        data: anyNamed('data'),
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

    test('should call DioClient.post on the upload-from-url path for the given account', () async {
      when(dioClient.post(
        any,
        data: anyNamed('data'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => {
        'accountId': accountId.id.value,
        'blobId': 'blob-id-123',
        'type': mimeType,
        'size': 2048,
      });

      await uploadFromUrlApi.uploadFromUrl(request);

      verify(dioClient.post(
        '/upload-from-url/${accountId.id.value}',
        data: anyNamed('data'),
        cancelToken: anyNamed('cancelToken'),
      )).called(1);
    });

    for (final statusCode in [400, 401, 403, 413, 429, 500, 502, 504]) {
      test('should propagate the unmapped DioException for status $statusCode', () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/upload-from-url/${accountId.id.value}'),
          response: Response(
            requestOptions: RequestOptions(path: '/upload-from-url/${accountId.id.value}'),
            statusCode: statusCode,
          ),
        );
        when(dioClient.post(
          any,
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
        )).thenThrow(dioException);

        expect(
          uploadFromUrlApi.uploadFromUrl(request),
          throwsA(same(dioException)),
        );
      });
    }

    test('should send the exact url/name/type payload and forward the cancelToken', () async {
      final cancelToken = CancelToken();
      final requestWithCancelToken = UploadFromUrlRequest(
        accountId: accountId,
        downloadLink: downloadLink,
        name: documentName,
        mimeType: mimeType,
        cancelToken: cancelToken,
      );
      when(dioClient.post(
        any,
        data: anyNamed('data'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => {
        'accountId': accountId.id.value,
        'blobId': 'blob-id-123',
        'type': mimeType,
        'size': 2048,
      });

      await uploadFromUrlApi.uploadFromUrl(requestWithCancelToken);

      final captured = verify(dioClient.post(
        '/upload-from-url/${accountId.id.value}',
        data: captureAnyNamed('data'),
        cancelToken: captureAnyNamed('cancelToken'),
      )).captured;
      expect(captured[0], {
        'url': downloadLink.toString(),
        'name': documentName,
        'type': mimeType,
      });
      expect(captured[1], same(cancelToken));
    });

    test('should never include the downloadLink value as the POST path', () async {
      when(dioClient.post(
        any,
        data: anyNamed('data'),
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
        data: anyNamed('data'),
        cancelToken: anyNamed('cancelToken'),
      )).captured.single as String;
      expect(capturedPath.contains(downloadLink.toString()), isFalse);
    });
  });
}
