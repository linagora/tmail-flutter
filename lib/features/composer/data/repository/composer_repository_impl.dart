
import 'package:dio/dio.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';

class ComposerRepositoryImpl extends ComposerRepository {

  final AttachmentUploadDataSource _attachmentUploadDataSource;

  ComposerRepositoryImpl(this._attachmentUploadDataSource);

  @override
  UploadAttachment uploadAttachment(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken}) {
    return _attachmentUploadDataSource.uploadAttachment(fileInfo, uploadUri, cancelToken: cancelToken);
  }
}