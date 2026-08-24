import 'package:dartz/dartz.dart';
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

    setUp(() {
      uploadFromUrlRepository = MockUploadFromUrlRepository();
      interactor = UploadDriveDocumentFromUrlInteractor(uploadFromUrlRepository);
    });

    test('should yield Right(UploadDriveDocumentFromUrlSuccess) with the repository\'s Attachment', () async {
      final attachment = Attachment(blobId: Id('blob-id-123'), name: documentName);
      when(uploadFromUrlRepository.uploadFromUrl(request))
          .thenAnswer((_) async => attachment);

      final stream = interactor.execute(request);

      await expectLater(
        stream,
        emitsInOrder([
          predicate<Either>((either) =>
              either.isRight() &&
              either.fold((l) => null, (r) => r) is UploadDriveDocumentFromUrlSuccess &&
              (either.fold((l) => null, (r) => r) as UploadDriveDocumentFromUrlSuccess)
                      .attachment ==
                  attachment),
          emitsDone,
        ]),
      );
    });

    test('should yield Left(UploadDriveDocumentFromUrlFailure) when the repository throws', () async {
      final exception = Exception('upload-from-url failed');
      when(uploadFromUrlRepository.uploadFromUrl(request)).thenThrow(exception);

      final stream = interactor.execute(request);

      await expectLater(
        stream,
        emitsInOrder([
          predicate<Either>((either) => either.fold(
            (failure) =>
                failure is UploadDriveDocumentFromUrlFailure &&
                identical(failure.exception, exception),
            (_) => false,
          )),
          emitsDone,
        ]),
      );
    });

    test('should yield Cancelled, not Failure, when the cancelToken was cancelled', () async {
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

      await expectLater(
        interactor.execute(cancellableRequest),
        emitsInOrder([
          predicate<Either>((either) =>
              either.fold((l) => l, (r) => r) is UploadDriveDocumentFromUrlCancelled),
          emitsDone,
        ]),
      );
    });
  });
}
