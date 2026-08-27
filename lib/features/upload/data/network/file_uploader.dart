
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

class FileUploader {

  static const String uploadAttachmentExtraKey = 'upload-attachment';
  static const String streamDataExtraKey = 'streamData';
  static const String filePathExtraKey = 'path';

  final DioClient _dioClient;
  final FileUtils _fileUtils;

  FileUploader(
    this._dioClient,
    this._fileUtils,
  );

  Future<Attachment> uploadAttachment(
      UploadTaskId uploadId,
      FileInfo fileInfo,
      Uri uploadUri,
      {
        CancelToken? cancelToken,
        StreamController<Either<Failure, Success>>? onSendController,
      }
  ) async {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.contentTypeHeader] = fileInfo.mimeType;
    headerParam[HttpHeaders.contentLengthHeader] = fileInfo.fileSize;

    final resultJson = await _dioClient.post(
      Uri.decodeFull(uploadUri.toString()),
      options: Options(
        headers: headerParam,
        extra: _buildUploadExtra(fileInfo)
      ),
      data: _buildRequestBody(fileInfo),
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        log('FileUploader::uploadAttachment():onSendProgress: FILE[${uploadId.id}] : { PROGRESS = $count | TOTAL = $total}');
        onSendController?.add(
          Right(UploadingAttachmentUploadState(
            uploadId,
            count,
            fileInfo.fileSize
          ))
        );
      }
    );
    log('FileUploader::uploadAttachment(): RESULT_JSON = $resultJson');
    return _parsingResponse(
      resultJson: resultJson,
      fileName: fileInfo.fileName,
      fileCharset: await _resolveCharset(fileInfo),
    );
  }

  bool _hasLocalFilePath(FileInfo fileInfo) => fileInfo.filePath?.isNotEmpty == true;

  Map<String, dynamic> _buildUploadExtra(FileInfo fileInfo) {
    final bytes = fileInfo.bytes;
    return <String, dynamic>{
      uploadAttachmentExtraKey: {
        if (_hasLocalFilePath(fileInfo))
          filePathExtraKey: fileInfo.filePath
        else if (bytes != null)
          streamDataExtraKey: BodyBytesStream.fromBytes(bytes),
      }
    };
  }

  Stream<List<int>>? _buildRequestBody(FileInfo fileInfo) {
    if (_hasLocalFilePath(fileInfo)) {
      return File(fileInfo.filePath!).openRead();
    }
    final bytes = fileInfo.bytes;
    return bytes != null ? BodyBytesStream.fromBytes(bytes) : null;
  }

  Future<String?> _resolveCharset(FileInfo fileInfo) async {
    if (fileInfo.mimeType != FileUtils.TEXT_PLAIN_MIME_TYPE) {
      return null;
    }

    final fileBytes = _hasLocalFilePath(fileInfo)
        ? await File(fileInfo.filePath!).readAsBytes()
        : fileInfo.bytes;
    if (fileBytes == null) {
      return null;
    }

    return (await _fileUtils.getCharsetFromBytes(fileBytes)).toLowerCase();
  }

  Attachment _parsingResponse({
    dynamic resultJson,
    required String fileName,
    String? fileCharset
  }) {
    if (resultJson != null) {
      final decodeJson = resultJson is Map ? resultJson : jsonDecode(resultJson);
      final uploadResponse = UploadResponse.fromJson(decodeJson);
      log('FileUploader::_parsingResponse(): UploadResponse = $uploadResponse');
      return uploadResponse.toAttachment(
        nameFile: fileName,
        charset: fileCharset);
    } else {
      logWarning('FileUploader::_parsingResponse(): DataResponseIsNullException');
      throw const DataResponseIsNullException();
    }
  }
}
