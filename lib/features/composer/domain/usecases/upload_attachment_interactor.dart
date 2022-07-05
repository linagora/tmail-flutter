import 'package:dio/dio.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';

class UploadAttachmentInteractor {
  final ComposerRepository _composerRepository;

  UploadAttachmentInteractor(this._composerRepository);

  UploadAttachment execute(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken}) {
    return _composerRepository.uploadAttachment(fileInfo, uploadUri, cancelToken: cancelToken);
  }
}