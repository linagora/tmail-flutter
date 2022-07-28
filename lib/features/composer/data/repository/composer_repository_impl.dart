
import 'package:dio/dio.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';

class ComposerRepositoryImpl extends ComposerRepository {

  final AttachmentUploadDataSource _attachmentUploadDataSource;
  final ComposerDataSource _composerDataSource;

  ComposerRepositoryImpl(
    this._attachmentUploadDataSource,
    this._composerDataSource);

  @override
  UploadAttachment uploadAttachment(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken}) {
    return _attachmentUploadDataSource.uploadAttachment(fileInfo, uploadUri, cancelToken: cancelToken);
  }

  @override
  Future<String?> downloadImageAsBase64(String url, String cid, FileInfo fileInfo, {double? maxWidth, bool? compress}) {
    return _composerDataSource.downloadImageAsBase64(url, cid, fileInfo, maxWidth: maxWidth, compress: compress);
  }
}