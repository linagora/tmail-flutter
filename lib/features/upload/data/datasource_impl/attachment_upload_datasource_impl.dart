
import 'package:dio/dio.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/data/datasource/attachment_upload_datasource.dart';
import 'package:tmail_ui_user/features/upload/data/network/file_uploader.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:uuid/uuid.dart';

class AttachmentUploadDataSourceImpl extends AttachmentUploadDataSource {

  final FileUploader _fileUploader;
  final Uuid _uuid;
  final ExceptionThrower _exceptionThrower;

  AttachmentUploadDataSourceImpl(this._fileUploader, this._uuid, this._exceptionThrower);

  @override
  Future<UploadAttachment> uploadAttachment(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken}) {
    return Future.sync(() {
      return UploadAttachment(
        UploadTaskId(_uuid.v4()),
        fileInfo,
        uploadUri,
        _fileUploader,
        _exceptionThrower,
        cancelToken: cancelToken
      )..upload();
    }).catchError(_exceptionThrower.throwException);
  }
}