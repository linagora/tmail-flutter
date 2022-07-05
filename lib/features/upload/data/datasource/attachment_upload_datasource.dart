
import 'package:dio/dio.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';

abstract class AttachmentUploadDataSource {
  UploadAttachment uploadAttachment(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken});
}