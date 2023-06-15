
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/data/model/upload_file_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';
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
    if (PlatformInfo.isWeb) {
      return _handleUploadAttachmentActionOnWeb(
          uploadId,
          onSendController,
          fileInfo,
          uploadUri,
          cancelToken: cancelToken);
    } else {
      return await _isolateExecutor.execute(
        arg1: UploadFileArguments(
          _dioClient,
          uploadId,
          fileInfo,
          uploadUri,
          cancelToken: cancelToken
        ),
        fun1: _handleUploadAttachmentAction,
        notification: (value) {
          if (value is Success) {
            log('FileUploader::uploadAttachment(): onUpdateProgress: $value');
            onSendController.add(Right(value));
          }
        }
      )
      .then((value) => value)
      .catchError((error) => throw error);
    }
  }

  static Future<Attachment?> _handleUploadAttachmentAction(
      UploadFileArguments argsUpload,
      worker.TypeSendPort sendPort
  ) async {
    final dioClient = argsUpload.dioClient;
    final fileInfo = argsUpload.fileInfo;
    final uploadUri = argsUpload.uploadUri;
    final cancelToken = argsUpload.cancelToken;

    final resultJson = await _invokeRequestToServer(
      dioClient,
      uploadUri,
      fileInfo,
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        log('FileUploader::_handleUploadAttachmentAction():onSendProgress: [${argsUpload.uploadId.id}] = $count');
        sendPort.send(
          UploadingAttachmentUploadState(
            argsUpload.uploadId,
            count,
            fileInfo.fileSize
          )
        );
      }
    );
    log('FileUploader::_handleUploadAttachmentAction():resultJson: $resultJson');
    if (cancelToken?.isCancelled == true) {
      log('FileUploader::_handleUploadAttachmentAction(): upload is cancelled');
      return null;
    }

    return _parsingResponse(resultJson: resultJson, fileName: fileInfo.fileName);
  }

  Future<Attachment?> _handleUploadAttachmentActionOnWeb(
    UploadTaskId uploadId,
    StreamController<Either<Failure, Success>> onSendController,
    FileInfo fileInfo,
    Uri uploadUri,
    {CancelToken? cancelToken}
  ) async {
    final resultJson = await _invokeRequestToServer(
      _dioClient,
      uploadUri,
      fileInfo,
      cancelToken: cancelToken,
      onSendProgress: (count, total) {
        log('FileUploader::_handleUploadAttachmentActionOnWeb():onSendProgress: [${uploadId.id}] = $count');
        onSendController.add(
          Right(UploadingAttachmentUploadState(
            uploadId,
            count,
            fileInfo.fileSize
          ))
        );
      }
    );

    log('FileUploader::_handleUploadAttachmentActionOnWeb():resultJson: $resultJson');

    if (cancelToken?.isCancelled == true) {
      log('FileUploader::_handleUploadAttachmentActionOnWeb(): upload is cancelled');
      return null;
    }

    return _parsingResponse(resultJson: resultJson, fileName: fileInfo.fileName);
  }

  static Future<dynamic> _invokeRequestToServer(
    DioClient dioClient,
    Uri uploadUri,
    FileInfo fileInfo, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress
  }) {
    final headerParam = dioClient.getHeaders();
    headerParam[HttpHeaders.contentTypeHeader] = fileInfo.mimeType;
    headerParam[HttpHeaders.contentLengthHeader] = fileInfo.fileSize;

    final data = fileInfo.readStream ?? File(fileInfo.filePath).openRead();

    if (cancelToken?.isCancelled == true) {
      log('FileUploader::_invokeRequestToServer(): upload is cancelled');
      return Future.value();
    }

    return dioClient.post(
      Uri.decodeFull(uploadUri.toString()),
      options: Options(headers: headerParam),
      data: data,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress
    );
  }

  static Attachment? _parsingResponse({dynamic resultJson, required String fileName}) {
    log('FileUploader::_parsingResponse():resultJson: $resultJson');
    if (resultJson != null) {
      final decodeJson = resultJson is Map ? resultJson : jsonDecode(resultJson);
      final uploadResponse = UploadResponse.fromJson(decodeJson);
      log('FileUploader::_parsingResponse():uploadResponse: ${uploadResponse.toString()}');
      return uploadResponse.toAttachment(fileName);
    } else {
      logError('FileUploader::_parsingResponse(): DataResponseIsNullException');
      throw DataResponseIsNullException();
    }
  }
}