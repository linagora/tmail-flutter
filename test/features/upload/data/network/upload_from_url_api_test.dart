import 'dart:io';
import 'dart:typed_data';

import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_from_url_api.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

import '../../../../fixtures/account_fixtures.dart';
import 'upload_from_url_api_test.mocks.dart';

// Captures the RequestOptions Dio actually builds, after merging per-request
// Options with Dio()'s global defaults - unlike a mocked DioClient, which
// only sees the Options passed into DioClient.post.
class _CapturingHttpClientAdapter implements HttpClientAdapter {
  RequestOptions? capturedRequestOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequestOptions = options;
    return ResponseBody.fromString(
      '{"accountId":"${AccountFixtures.aliceAccountId.id.value}","blobId":"blob-id-123","type":"application/pdf","size":2048}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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

    test('should propagate the unmapped DioException on a failed upload', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: uploadUri.toString()),
        response: Response(
          requestOptions: RequestOptions(path: uploadUri.toString()),
          statusCode: 500,
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

    test('should fall back to octet-stream mimeType header on the wire WHEN it is blank', () async {
      final requestWithBlankMimeType = UploadFromUrlRequest(
        accountId: accountId,
        uploadUri: uploadUri,
        attachmentUrl: downloadLink,
        name: documentName,
        mimeType: '',
      );
      final adapter = _CapturingHttpClientAdapter();
      final realDioClient = DioClient(
        Dio(BaseOptions(contentType: Headers.jsonContentType))
          ..httpClientAdapter = adapter,
      );

      await UploadFromUrlApi(realDioClient).uploadFromUrl(requestWithBlankMimeType);

      final sentHeaders = adapter.capturedRequestOptions!.headers;
      expect(sentHeaders[HttpHeaders.contentTypeHeader], Constant.octetStreamMimeType);
    });

    test('should override the global JSON content-type on the actual outgoing request', () async {
      final adapter = _CapturingHttpClientAdapter();
      final realDioClient = DioClient(Dio()..httpClientAdapter = adapter);
      final realUploadFromUrlApi = UploadFromUrlApi(realDioClient);

      await realUploadFromUrlApi.uploadFromUrl(request);

      final sentHeaders = adapter.capturedRequestOptions!.headers;
      expect(sentHeaders[HttpHeaders.contentTypeHeader], mimeType);
      expect(sentHeaders[HttpHeaders.contentTypeHeader], isNot(Headers.jsonContentType));
    });

    test('should POST with no body and keep Content-Location on the wire', () async {
      final adapter = _CapturingHttpClientAdapter();
      final realDioClient = DioClient(Dio()..httpClientAdapter = adapter);

      await UploadFromUrlApi(realDioClient).uploadFromUrl(request);

      final sent = adapter.capturedRequestOptions!;
      expect(sent.data, isNull);
      expect(
        sent.headers[HttpHeaders.contentLocationHeader],
        downloadLink.toString(),
      );
    });

    test('should throw WHEN the upload response JSON is malformed', () async {
      when(dioClient.post(
        any,
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
      )).thenAnswer((_) async => <String, dynamic>{});

      expect(uploadFromUrlApi.uploadFromUrl(request), throwsA(isA<TypeError>()));
    });
  });
}
