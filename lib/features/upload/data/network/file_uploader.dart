
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
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

  FileUploader(this._dioClient, this._fileUtils);

  Future<Attachment> uploadAttachment(
      UploadTaskId uploadId,
      FileInfo fileInfo,
      Uri uploadUri,
      {
        CancelToken? cancelToken,
        StreamController<Either<Failure, Success>>? onSendController,
      }
  ) async {
    try {
      final resultJson = await _dioClient.post(
        Uri.decodeFull(uploadUri.toString()),
        options: _getDioOptions(fileInfo),
        data: _getDataUploadRequest(fileInfo),
        cancelToken: cancelToken,
        onSendProgress: (count, total) => _onProgressChanged(
          uploadId: uploadId,
          count: count,
          total: total,
          fileSize: fileInfo.fileSize,
          onSendController: onSendController,
        ),
      );

      log('FileUploader::_handleUploadAttachmentAction(): RESULT_JSON = $resultJson');

      if (fileInfo.mimeType == FileUtils.TEXT_PLAIN_MIME_TYPE) {
        return _parsingJsonResponseWithFileTextPlain(
          resultJson: resultJson,
          fileInfo: fileInfo,
        );
      } else {
        return _parsingResponse(
          resultJson: resultJson,
          fileName: fileInfo.fileName,
        );
      }
    } on DioError catch (exception) {
      logError('FileUploader::_handleUploadAttachmentAction():DioError: $exception');

      throw exception.copyWith(
          requestOptions: exception.requestOptions.copyWith(data: ''));
    } catch (exception) {
      logError('FileUploader::_handleUploadAttachmentAction():OtherException: $exception');

      rethrow;
    }
  }

  Options _getDioOptions(FileInfo fileInfo) {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.contentTypeHeader] = fileInfo.mimeType;
    headerParam[HttpHeaders.contentLengthHeader] = fileInfo.fileSize;

    final mapExtra = <String, dynamic>{
      uploadAttachmentExtraKey: {
        if (fileInfo.filePath?.isNotEmpty == true)
          filePathExtraKey: fileInfo.filePath,
        if (fileInfo.bytes?.isNotEmpty == true)
          streamDataExtraKey: BodyBytesStream.fromBytes(fileInfo.bytes!),
      }
    };

    return Options(headers: headerParam, extra: mapExtra);
  }

  Stream<List<int>>? _getDataUploadRequest(FileInfo fileInfo) {
    try {
      if (PlatformInfo.isMobile && fileInfo.filePath?.isNotEmpty == true) {
        return File(fileInfo.filePath!).openRead();
      } else if (fileInfo.bytes != null) {
        return BodyBytesStream.fromBytes(fileInfo.bytes!);
      } else {
        return null;
      }
    } catch(e) {
      logError('FileUploader::_getDataUploadRequest: Exception = $e');
      return null;
    }
  }

  void _onProgressChanged({
    required UploadTaskId uploadId,
    required int count,
    required int total,
    required int fileSize,
    StreamController<Either<Failure, Success>>? onSendController,
  }) {
    log('FileUploader::_onProgressChanged: FILE[${uploadId.id}] : { PROGRESS = $count | TOTAL = $total}');
    onSendController?.add(Right(UploadingAttachmentUploadState(
      uploadId,
      count,
      fileSize,
    )));
  }

  Future<Attachment> _parsingJsonResponseWithFileTextPlain({
    dynamic resultJson,
    required FileInfo fileInfo,
  }) async {
    if (PlatformInfo.isMobile && fileInfo.filePath?.isNotEmpty == true) {
      final fileBytes = await File(fileInfo.filePath!).readAsBytes();
      final fileCharset = await _fileUtils.getCharsetFromBytes(fileBytes);
      return _parsingResponse(
        resultJson: resultJson,
        fileName: fileInfo.fileName,
        fileCharset: fileCharset.toLowerCase(),
      );
    } else if (fileInfo.bytes?.isNotEmpty == true) {
      final fileCharset = await _fileUtils.getCharsetFromBytes(fileInfo.bytes!);
      return _parsingResponse(
        resultJson: resultJson,
        fileName: fileInfo.fileName,
        fileCharset: fileCharset.toLowerCase(),
      );
    } else {
      return _parsingResponse(
        resultJson: resultJson,
        fileName: fileInfo.fileName,
      );
    }
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
      logError('FileUploader::_parsingResponse(): DataResponseIsNullException');
      throw DataResponseIsNullException();
    }
  }
}