import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';

class DownloadImageAsBase64Interactor {
  final ComposerRepository _composerRepository;

  DownloadImageAsBase64Interactor(this._composerRepository);

  Stream<Either<Failure, Success>> execute(
      String url,
      String cid,
      FileInfo fileInfo,
      {
        double? maxWidth,
        bool? compress
      }
  ) async* {
    try {
      yield Right<Failure, Success>(DownloadingImageAsBase64());
      final result = await _composerRepository.downloadImageAsBase64(
          url,
          cid,
          fileInfo,
          maxWidth: maxWidth,
          compress: compress);
      if (result?.isNotEmpty == true) {
        yield Right<Failure, Success>(DownloadImageAsBase64Success(result!, cid, fileInfo));
      } else {
        yield Left<Failure, Success>(DownloadImageAsBase64Failure(null));
      }
    } catch (exception) {
      yield Left<Failure, Success>(DownloadImageAsBase64Failure(exception));
    }
  }
}