import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_repository.dart';
import 'package:tmail_ui_user/features/upload/domain/repository/upload_from_url_request.dart';
import 'package:tmail_ui_user/features/upload/domain/state/upload_drive_document_from_url_state.dart';

class UploadDriveDocumentFromUrlInteractor {
  final UploadFromUrlRepository _uploadFromUrlRepository;

  UploadDriveDocumentFromUrlInteractor(this._uploadFromUrlRepository);

  Future<Either<Failure, Success>> execute(UploadFromUrlRequest request) async {
    try {
      final attachment = await _uploadFromUrlRepository.uploadFromUrl(request);
      return Right<Failure, Success>(UploadDriveDocumentFromUrlSuccess(attachment));
    } catch (e, s) {
      final isCancelled = request.cancelToken?.isCancelled == true;
      // Single logging point for everything the repository/datasource/API
      // layers throw (account mismatch, Dio errors, JSON parse errors).
      if (!isCancelled) {
        logError(
          'UploadDriveDocumentFromUrlInteractor::execute failed',
          exception: e,
          stackTrace: s,
          // Identifying values stay out: extras reach Sentry.
          extras: {'mimeType': request.mimeType},
        );
      }
      return Left<Failure, Success>(
        isCancelled
          ? UploadDriveDocumentFromUrlCancelled()
          : UploadDriveDocumentFromUrlFailure(e),
      );
    }
  }
}
