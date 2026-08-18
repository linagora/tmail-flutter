import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_repository.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';
import 'package:tmail_ui_user/features/upload/domain/state/upload_drive_document_from_url_state.dart';

class UploadDriveDocumentFromUrlInteractor {
  final UploadFromUrlRepository _uploadFromUrlRepository;

  UploadDriveDocumentFromUrlInteractor(this._uploadFromUrlRepository);

  Stream<Either<Failure, Success>> execute(UploadFromUrlRequest request) async* {
    try {
      final attachment = await _uploadFromUrlRepository.uploadFromUrl(request);
      yield Right<Failure, Success>(UploadDriveDocumentFromUrlSuccess(attachment));
    } catch (e) {
      yield Left<Failure, Success>(
        request.cancelToken?.isCancelled == true
          ? UploadDriveDocumentFromUrlCancelled()
          : UploadDriveDocumentFromUrlFailure(e),
      );
    }
  }
}
