import 'package:dio/dio.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_attachment.dart';

abstract class ComposerRepository {
  UploadAttachment uploadAttachment(FileInfo fileInfo, Uri uploadUri, {CancelToken? cancelToken});

  Future<String?> downloadImageAsBase64(String url, String cid, FileInfo fileInfo, {double? maxWidth, bool? compress});
}