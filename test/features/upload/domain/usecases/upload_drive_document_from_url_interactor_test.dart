import 'package:core/utils/logging/app_logger_registry.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_repository.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';
import 'package:tmail_ui_user/features/upload/domain/state/upload_drive_document_from_url_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/upload_drive_document_from_url_interactor.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/capturing_log_handler.dart';
import 'upload_drive_document_from_url_interactor_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UploadFromUrlRepository>()])
void main() {
  group('UploadDriveDocumentFromUrlInteractor::execute', () {
    late MockUploadFromUrlRepository uploadFromUrlRepository;
    late UploadDriveDocumentFromUrlInteractor interactor;


    final uploadUri = Uri.parse('https://mail.example.com/upload-from-url/${AccountFixtures.aliceAccountId.id.value}');
    final downloadLink = Uri.parse('https://drive.example.com/secret-token/file.pdf');
    const documentName = 'report.pdf';
    const mimeType = 'application/pdf';
    final request = UploadFromUrlRequest(
      accountId: AccountFixtures.aliceAccountId,
      uploadUri: uploadUri,
      attachmentUrl: downloadLink,
      name: documentName,
      mimeType: mimeType,
    );

    late CapturingLogHandler logHandler;

    setUp(() {
      uploadFromUrlRepository = MockUploadFromUrlRepository();
      interactor = UploadDriveDocumentFromUrlInteractor(uploadFromUrlRepository);
      logHandler = CapturingLogHandler();
      AppLoggerRegistry.instance.registerHandler(logHandler);
    });

    tearDown(() => AppLoggerRegistry.instance.resetForTesting());

    test('should return Right(UploadDriveDocumentFromUrlSuccess) with the repository\'s Attachment', () async {
      final attachment = Attachment(blobId: Id('blob-id-123'), name: documentName);
      when(uploadFromUrlRepository.uploadFromUrl(request))
          .thenAnswer((_) async => attachment);

      final result = await interactor.execute(request);

      expect(result.isRight(), isTrue);
      final success = result.fold((l) => null, (r) => r);
      expect(success, isA<UploadDriveDocumentFromUrlSuccess>());
      expect((success as UploadDriveDocumentFromUrlSuccess).attachment, attachment);
    });

    test('should return Left(UploadDriveDocumentFromUrlFailure) when the repository throws', () async {
      final exception = Exception('upload-from-url failed');
      when(uploadFromUrlRepository.uploadFromUrl(request)).thenThrow(exception);

      final result = await interactor.execute(request);

      final failure = result.fold((l) => l, (r) => r);
      expect(failure, isA<UploadDriveDocumentFromUrlFailure>());
      expect(
        identical((failure as UploadDriveDocumentFromUrlFailure).exception, exception),
        isTrue,
      );
    });

    test('should return Cancelled, not Failure, when the cancelToken was cancelled', () async {
      final cancelToken = CancelToken();
      final cancellableRequest = UploadFromUrlRequest(
        accountId: AccountFixtures.aliceAccountId,
        uploadUri: uploadUri,
        attachmentUrl: downloadLink,
        name: documentName,
        mimeType: mimeType,
        cancelToken: cancelToken,
      );
      when(uploadFromUrlRepository.uploadFromUrl(cancellableRequest))
          .thenAnswer((_) async {
        cancelToken.cancel();
        throw DioException.requestCancelled(
          requestOptions: RequestOptions(path: '/upload-from-url'),
          reason: null);
      });

      final result = await interactor.execute(cancellableRequest);

      expect(
        result.fold((l) => l, (r) => r),
        isA<UploadDriveDocumentFromUrlCancelled>(),
      );
      expect(
        logHandler.errorRecords,
        isEmpty,
        reason: 'a user-cancelled transfer is not a failure worth reporting',
      );
    });

    test(
      'WHEN the repository throws for a request carrying an upload URL, '
      'account id and file name\n'
      'THEN exactly ONE error event is emitted\n'
      'AND none of those values appear in extras or the message',
      () async {
        // Sentinels: distinctive enough that a substring match cannot be a
        // coincidence if any of them leaks into the event.
        final sensitiveUploadUri = Uri.parse('https://mail.example.com/upload-from-url/SENSITIVE-ACCOUNT-9f3c');
        final sensitiveDownloadLink = Uri.parse('https://drive.example.com/SENSITIVE-TOKEN-4b7a/file.pdf');
        const sensitiveName = 'SENSITIVE-PAYSLIP-2026.pdf';
        final sensitiveRequest = UploadFromUrlRequest(
          accountId: AccountFixtures.aliceAccountId,
          uploadUri: sensitiveUploadUri,
          attachmentUrl: sensitiveDownloadLink,
          name: sensitiveName,
          mimeType: mimeType,
        );
        when(uploadFromUrlRepository.uploadFromUrl(sensitiveRequest))
            .thenThrow(Exception('backend rejected the upload'));

        await interactor.execute(sensitiveRequest);

        expect(logHandler.errorRecords, hasLength(1));
        final record = logHandler.errorRecords.single;

        expect(record.extras?.keys, isNot(contains('accountId')));
        expect(record.extras?.keys, isNot(contains('name')));
        expect(record.extras?.keys, isNot(contains('uploadUri')));
        // rawMessage concatenates message, exception, extras and stack trace,
        // so this catches a leak through any of those channels.
        expect(record.rawMessage, isNot(contains('SENSITIVE-ACCOUNT-9f3c')));
        expect(record.rawMessage, isNot(contains('SENSITIVE-TOKEN-4b7a')));
        expect(record.rawMessage, isNot(contains(sensitiveName)));
        expect(record.rawMessage, isNot(contains(AccountFixtures.aliceAccountId.id.value)));
        // Allow-listed technical metadata is retained.
        expect(record.extras, containsPair('mimeType', mimeType));
        expect(record.exception, isNotNull);
        expect(record.stackTrace, isNotNull);
      },
    );
  });
}
