import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/download/domain/state/get_preview_email_eml_content_shared_state.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';

class GetPreviewEmailEMLContentSharedInteractor {
  final DownloadRepository _downloadRepository;

  const GetPreviewEmailEMLContentSharedInteractor(this._downloadRepository);

  Stream<Either<Failure, Success>> execute(String keyStored) async* {
    try {
      yield Right<Failure, Success>(GettingPreviewEmailEMLContentShared());

      final previewEMLContent = await _downloadRepository
        .getPreviewEmailEMLContentShared(keyStored);

      yield Right<Failure, Success>(GetPreviewEmailEMLContentSharedSuccess(previewEMLContent));
    } catch (e) {
      yield Left<Failure, Success>(GetPreviewEmailEMLContentSharedFailure(
        keyStored: keyStored,
        exception: e,
      ));
    }
  }
}