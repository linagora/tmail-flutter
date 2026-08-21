import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/upload_from_url_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/repository/upload_from_url_repository_impl.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_from_url_account_mismatch_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';

import '../../../../fixtures/account_fixtures.dart';
import 'upload_from_url_repository_impl_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UploadFromUrlDataSource>()])
void main() {
  group('UploadFromUrlRepositoryImpl::uploadFromUrl', () {
    late MockUploadFromUrlDataSource uploadFromUrlDataSource;
    late UploadFromUrlRepositoryImpl repository;

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
      uploadFromUrlDataSource = MockUploadFromUrlDataSource();
      repository = UploadFromUrlRepositoryImpl(uploadFromUrlDataSource);
    });

    test('should return Attachment built from the datasource UploadResponse', () async {
      final uploadResponse = UploadResponse(
        accountId,
        Id('blob-id-123'),
        MediaType.parse(mimeType),
        2048,
      );
      when(uploadFromUrlDataSource.uploadFromUrl(request))
          .thenAnswer((_) async => uploadResponse);

      final attachment = await repository.uploadFromUrl(request);

      expect(attachment.blobId, uploadResponse.blobId);
      expect(attachment.type, uploadResponse.type);
      expect(attachment.size, UnsignedInt(uploadResponse.size));
      expect(attachment.name, documentName);
    });

    test('should let the underlying datasource exception propagate unmapped', () async {
      final exception = Exception('upload-from-url failed');
      when(uploadFromUrlDataSource.uploadFromUrl(request)).thenThrow(exception);

      expect(
        repository.uploadFromUrl(request),
        throwsA(same(exception)),
      );
    });

    test('should throw UploadFromUrlAccountMismatchException WHEN the response accountId differs from the requested accountId', () async {
      final otherAccountId = AccountId(Id('other-account-id'));
      final uploadResponse = UploadResponse(
        otherAccountId,
        Id('blob-id-123'),
        MediaType.parse(mimeType),
        2048,
      );
      when(uploadFromUrlDataSource.uploadFromUrl(request))
          .thenAnswer((_) async => uploadResponse);

      expect(
        repository.uploadFromUrl(request),
        throwsA(isA<UploadFromUrlAccountMismatchException>()),
      );
    });
  });
}
