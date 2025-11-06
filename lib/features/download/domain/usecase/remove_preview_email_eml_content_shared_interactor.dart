import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/download/domain/state/remove_preview_email_eml_content_shared_state.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';

class RemovePreviewEmailEmlContentSharedInteractor {
  final DownloadRepository _downloadRepository;

  const RemovePreviewEmailEmlContentSharedInteractor(this._downloadRepository);

  Stream<Either<Failure, Success>> execute(String keyStored) async* {
    try {
      yield Right<Failure, Success>(RemovingPreviewEmailEMLContentShared());
      await _downloadRepository.removePreviewEmailEMLContentShared(keyStored);
      yield Right<Failure, Success>(RemovePreviewEmailEMLContentSharedSuccess());
    } catch (e) {
      yield Left<Failure, Success>(RemovePreviewEmailEMLContentSharedFailure(e));
    }
  }
}