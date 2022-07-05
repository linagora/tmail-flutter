
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/data/model/upload_file_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:worker_manager/worker_manager.dart' as worker;

class FileUploader {

  final DioClient _dioClient;
  final worker.Executor _isolateExecutor;

  FileUploader(this._dioClient, this._isolateExecutor);

  Future<Attachment?> uploadAttachment(
      UploadTaskId uploadId,
      StreamController<Either<Failure, Success>> onSendController,
      FileInfo fileInfo,
      Uri uploadUri,
      {CancelToken? cancelToken}
  ) async {
    if (BuildUtils.isWeb) {
      return _handleUploadAttachmentActionOnWeb(
          uploadId,
          onSendController,
          fileInfo,
          uploadUri,
          cancelToken: cancelToken);
    } else {
      final attachmentUploaded = await _isolateExecutor.execute(
          arg1: UploadFileArguments(
              _dioClient,
              uploadId,
              fileInfo,
              uploadUri,
              cancelToken: cancelToken),
          fun1: _handleUploadAttachmentAction,
          notification: (value) {
            if (value is Success) {
              log('FileUploader::uploadAttachment(): onUpdateProgress: $value');
              onSendController.add(Right(value));
            }
          });
      return attachmentUploaded;
    }
  }

  static Future<Attachment?> _handleUploadAttachmentAction(
      UploadFileArguments argsUpload,
      worker.TypeSendPort sendPort
  ) async {
    try {
      final dioClient = argsUpload.dioClient;
      final fileInfo = argsUpload.fileInfo;
      final uploadUri = argsUpload.uploadUri;
      final cancelToken = argsUpload.cancelToken;

      final headerParam = dioClient.getHeaders();
      headerParam[HttpHeaders.contentTypeHeader] = fileInfo.mimeType;
      headerParam[HttpHeaders.contentLengthHeader] = fileInfo.fileSize;

      final resultJson = await argsUpload.dioClient.post(
          Uri.decodeFull(uploadUri.toString()),
          options: Options(headers: headerParam),
          data: fileInfo.readStream,
          cancelToken: cancelToken,
          onSendProgress: (progress, total) {
            log('FileUploader::_handleUploadAttachmentAction():onSendProgress: [${argsUpload.uploadId.id}] = $progress');
            sendPort.send(UploadingAttachmentUploadState(
                argsUpload.uploadId,
                progress,
                fileInfo.fileSize));
          });

      if (cancelToken?.isCancelled == true) {
        log('FileUploader::_handleUploadAttachmentAction(): cancelToken');
        return null;
      }

      final decodeJson = resultJson is Map ? resultJson : jsonDecode(resultJson);
      final uploadResponse = UploadResponse.fromJson(decodeJson);
      log('FileUploader::_handleUploadAttachmentAction(): ${uploadResponse.toString()}');
      return uploadResponse.toAttachment(fileInfo.fileName);
    } catch (e) {
      log('FileUploader::_handleUploadAttachmentAction(): ERROR: $e');
      return null;
    }
  }

  Future<Attachment?> _handleUploadAttachmentActionOnWeb(
      UploadTaskId uploadId,
      StreamController<Either<Failure, Success>> onSendController,
      FileInfo fileInfo,
      Uri uploadUri,
      {CancelToken? cancelToken}
  ) async {
    try {
      final headerParam = _dioClient.getHeaders();
      headerParam[HttpHeaders.contentTypeHeader] = fileInfo.mimeType;
      headerParam[HttpHeaders.contentLengthHeader] = fileInfo.fileSize;

      final resultJson = await _dioClient.post(
          Uri.decodeFull(uploadUri.toString()),
          options: Options(headers: headerParam),
          data: fileInfo.readStream,
          cancelToken: cancelToken,
          onSendProgress: (progress, total) {
            log('FileUploader::_handleUploadAttachmentActionOnWeb():onSendProgress: [$uploadId] = $progress');
            onSendController.add(Right(UploadingAttachmentUploadState(
                uploadId, progress, fileInfo.fileSize)));
          }
      );

      if (cancelToken?.isCancelled == true) {
        log('FileUploader::_handleUploadAttachmentAction(): cancelToken');
        return null;
      }

      final decodeJson = resultJson is Map ? resultJson : jsonDecode(resultJson);
      final uploadResponse = UploadResponse.fromJson(decodeJson);
      log('FileUploader::_handleUploadAttachmentActionOnWeb(): ${uploadResponse.toString()}');
      return uploadResponse.toAttachment(fileInfo.fileName);
    } catch (e) {
      log('FileUploader::_handleUploadAttachmentActionOnWeb(): $e');
      return null;
    }
  }
}