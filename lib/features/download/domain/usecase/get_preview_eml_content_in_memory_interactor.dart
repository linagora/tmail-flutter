import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:tmail_ui_user/features/download/domain/state/get_preview_eml_content_in_memory_state.dart';
import 'package:tmail_ui_user/features/download/domain/repository/download_repository.dart';

class GetPreviewEmlContentInMemoryInteractor {
  final DownloadRepository _downloadRepository;

  const GetPreviewEmlContentInMemoryInteractor(this._downloadRepository);

  Stream<Either<Failure, Success>> execute(String keyStored) async* {
    try {
      yield Right<Failure, Success>(GettingPreviewEMLContentInMemory());
      final emlPreviewer = await _downloadRepository.getPreviewEMLContentInMemory(keyStored);
      yield Right<Failure, Success>(GetPreviewEMLContentInMemorySuccess(emlPreviewer));
    } catch (e) {
      yield Left<Failure, Success>(GetPreviewEMLContentInMemoryFailure(
        keyStored: keyStored,
        exception: e,
      ));
    }
  }
}