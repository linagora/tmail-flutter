import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/download/domain/state/move_preview_eml_content_from_persistent_to_memory_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/eml_previewer.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';

class MovePreviewEmlContentFromPersistentToMemoryInteractor {
  final DownloadRepository _downloadRepository;

  const MovePreviewEmlContentFromPersistentToMemoryInteractor(
    this._downloadRepository,
  );

  Stream<Either<Failure, Success>> execute(EMLPreviewer emlPreviewer) async* {
    try {
      yield Right<Failure, Success>(MovingPreviewEmailEMLContentFromPersistentToMemory());
      await Future.wait([
        _downloadRepository.removePreviewEmailEMLContentShared(emlPreviewer.id),
        _downloadRepository.storePreviewEMLContentToSessionStorage(emlPreviewer),
      ]);
      yield Right<Failure, Success>(MovePreviewEmailEMLContentFromPersistentToMemorySuccess());
    } catch (e) {
      yield Left<Failure, Success>(MovePreviewEmailEMLContentFromPersistentToMemoryFailure(e));
    }
  }
}