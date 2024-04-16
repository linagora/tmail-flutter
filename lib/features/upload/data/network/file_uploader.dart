
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
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/upload/data/model/upload_file_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/file_info_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/main/exceptions/isolate_exception.dart';
import 'package:worker_manager/worker_manager.dart' as worker;

class FileUploader {

  static const String uploadAttachmentExtraKey = 'upload-attachment';
  static const String platformExtraKey = 'platform';
  static const String bytesExtraKey = 'bytes';
  static const String typeExtraKey = 'type';
  static const String sizeExtraKey = 'size';
  static const String filePathExtraKey = 'path';

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
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) {
        throw CanNotGetRootIsolateToken();
      }

      final mobileFileUpload = fileInfo.toMobileFileUpload();
      return await _isolateExecutor.execute(
        arg1: UploadFileArguments(
          _dioClient,
          uploadId,
          mobileFileUpload,
          uploadUri,
          rootIsolateToken,
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
    try {
      final rootIsolateToken = argsUpload.isolateToken;
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      await HiveCacheConfig.instance.setUp();

      final headerParam = argsUpload.dioClient.getHeaders();
      headerParam[HttpHeaders.contentTypeHeader] = argsUpload.mobileFileUpload.mimeType;
      headerParam[HttpHeaders.contentLengthHeader] = argsUpload.mobileFileUpload.fileSize;

      final mapExtra = <String, dynamic>{
        uploadAttachmentExtraKey: {
          platformExtraKey: 'mobile',
          filePathExtraKey: argsUpload.mobileFileUpload.filePath,
          typeExtraKey: argsUpload.mobileFileUpload.mimeType,
          sizeExtraKey: argsUpload.mobileFileUpload.fileSize,
        }
      };

      final resultJson = await argsUpload.dioClient.post(
        Uri.decodeFull(argsUpload.uploadUri.toString()),
        options: Options(
          headers: headerParam,
          extra: mapExtra
        ),
        data: File(argsUpload.mobileFileUpload.filePath).openRead(),
        onSendProgress: (count, total) {
          log('FileUploader::_handleUploadAttachmentAction():onSendProgress: [${argsUpload.uploadId.id}] = $count');
          sendPort.send(
            UploadingAttachmentUploadState(
              argsUpload.uploadId,
              count,
              argsUpload.mobileFileUpload.fileSize
            )
          );
        }
      );
      log('FileUploader::_handleUploadAttachmentAction():resultJson: $resultJson');
      return _parsingResponse(
        resultJson: resultJson,
        fileName: argsUpload.mobileFileUpload.fileName
      );
    } on DioError catch (exception) {
      logError('FileUploader::_handleUploadAttachmentAction():DioError: $exception');

      throw exception.copyWith(
        requestOptions: exception.requestOptions.copyWith(data: ''));
    } catch (exception) {
      logError('FileUploader::_handleUploadAttachmentAction():OtherException: $exception');
      
      rethrow;
    }
  }

  Future<Attachment?> _handleUploadAttachmentActionOnWeb(
    UploadTaskId uploadId,
    StreamController<Either<Failure, Success>> onSendController,
    FileInfo fileInfo,
    Uri uploadUri,
    {CancelToken? cancelToken}
  ) async {
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.contentTypeHeader] = fileInfo.mimeType;
    headerParam[HttpHeaders.contentLengthHeader] = fileInfo.fileSize;

    final mapExtra = <String, dynamic>{
      uploadAttachmentExtraKey: {
        platformExtraKey: 'web',
        bytesExtraKey: fileInfo.bytes,
        typeExtraKey: fileInfo.mimeType,
        sizeExtraKey: fileInfo.fileSize,
      }
    };

    final resultJson = await _dioClient.post(
      Uri.decodeFull(uploadUri.toString()),
      options: Options(
        headers: headerParam,
        extra: mapExtra
      ),
      data: BodyBytesStream.fromBytes(fileInfo.bytes!),
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
    return _parsingResponse(resultJson: resultJson, fileName: fileInfo.fileName);
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