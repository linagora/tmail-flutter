import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/data/datasource_impl/upload_from_url_datasource_impl.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_from_url_api.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';
import 'package:tmail_ui_user/main/exceptions/remote/unknown_remote_exception.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

import '../../../../fixtures/account_fixtures.dart';
import 'upload_from_url_datasource_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UploadFromUrlApi>(),
  MockSpec<ExceptionThrower>(),
])
void main() {
  final uploadFromUrlApi = MockUploadFromUrlApi();
  final exceptionThrower = MockExceptionThrower();
  final uploadFromUrlDataSource = UploadFromUrlDataSourceImpl(
    uploadFromUrlApi,
    exceptionThrower,
  );

  final accountId = AccountFixtures.aliceAccountId;

  final uploadUri = Uri.parse('https://mail.example.com/upload-from-url/${AccountFixtures.aliceAccountId.id.value}');
  final request = UploadFromUrlRequest(
    accountId: accountId,
    uploadUri: uploadUri,
    attachmentUrl: Uri.parse('https://drive.example.com/secret-token/file.pdf'),
    name: 'report.pdf',
    mimeType: 'application/pdf',
  );

  group('upload from url datasource impl test:', () {
    test(
      'should return the UploadResponse from UploadFromUrlApi '
      'when uploadFromUrl succeeds',
    () async {
      // arrange
      final uploadResponse = UploadResponse(
        accountId,
        Id('blob-id-123'),
        MediaType.parse('application/pdf'),
        2048,
      );
      when(uploadFromUrlApi.uploadFromUrl(request))
        .thenAnswer((_) async => uploadResponse);

      // act
      final result = await uploadFromUrlDataSource.uploadFromUrl(request);

      // assert
      expect(result, uploadResponse);
    });

    test(
      'should sanitize the DioException via ExceptionThrower '
      'instead of letting the tokenized url leak through '
      'when UploadFromUrlApi throws a DioException',
    () async {
      // arrange
      final dioException = DioException(
        requestOptions: RequestOptions(
          path: '/upload-from-url/${accountId.id.value}',
          data: {'url': request.attachmentUrl.toString()},
        ),
      );
      const sanitizedException = UnknownRemoteException();
      when(uploadFromUrlApi.uploadFromUrl(request)).thenThrow(dioException);
      when(exceptionThrower.throwException(dioException, any))
        .thenThrow(sanitizedException);

      // act & assert
      await expectLater(
        uploadFromUrlDataSource.uploadFromUrl(request),
        throwsA(same(sanitizedException)),
      );
    });
  });
}
