import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';

class UploadAttachmentInteractor {
  final ComposerRepository _composerRepository;

  UploadAttachmentInteractor(this._composerRepository);

  Stream<Either<Failure, Success>> execute(
    FileInfo fileInfo,
    Uri uploadUri, {
    CancelToken? cancelToken,
  }) async* {
    try {
      final uploadAttachment = await _composerRepository.uploadAttachment(
        fileInfo,
        uploadUri,
        cancelToken: cancelToken
      );
      yield Right<Failure, Success>(UploadAttachmentSuccess(uploadAttachment));
    } catch (e) {
      yield Left<Failure, Success>(UploadAttachmentFailure(e, fileInfo));
    }
  }
}