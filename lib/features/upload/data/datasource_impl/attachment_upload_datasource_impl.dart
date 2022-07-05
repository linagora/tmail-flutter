
import 'package:dio/dio.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:uuid/uuid.dart';

class AttachmentUploadDataSourceImpl extends AttachmentUploadDataSource {

  final FileUploader _fileUploader;

  AttachmentUploadDataSourceImpl(this._fileUploader);

  @override
  UploadAttachment uploadAttachment(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken}) {
    final attachmentUploadId = _generateAttachmentUploadId();
    final uploadAttachment = UploadAttachment(
          attachmentUploadId,
          fileInfo,
          uploadUri,
          _fileUploader,
          cancelToken: cancelToken)
      ..upload();

    return uploadAttachment;
  }

  UploadTaskId _generateAttachmentUploadId() {
    return UploadTaskId(const Uuid().v4());
  }
}