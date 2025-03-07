
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
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/upload/data/model/upload_file_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/main/exceptions/isolate_exception.dart';
import 'package:worker_manager/worker_manager.dart' as worker;

class FileUploader {

  static const String uploadAttachmentExtraKey = 'upload-attachment';
  static const String streamDataExtraKey = 'streamData';
  static const String filePathExtraKey = 'path';

  final DioClient _dioClient;
  final worker.Executor _isolateExecutor;
  final FileUtils _fileUtils;

  FileUploader(
    this._dioClient,
    this._isolateExecutor,
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
    if (PlatformInfo.isWeb) {
      return _handleUploadAttachmentActionOnWeb(
          uploadId,
          fileInfo,
          uploadUri,
          cancelToken: cancelToken,
          onSendController: onSendController,
      );
    } else {
      final rootIsolateToken = RootIsolateToken.instance;
      if (rootIsolateToken == null) {
        throw CanNotGetRootIsolateToken();
      }

      return await _isolateExecutor.execute(
        arg1: UploadFileArguments(
          _dioClient,
          _fileUtils,
          uploadId,
          fileInfo,
          uploadUri,
          rootIsolateToken,
        ),
        fun1: _handleUploadAttachmentAction,
        notification: (value) {
          if (value is Success) {
            log('FileUploader::uploadAttachment(): onUpdateProgress: $value');
            onSendController?.add(Right(value));
          }
        }
      )
      .then((value) => value)
      .catchError((error) => throw error);
    }
  }

  static Future<Attachment> _handleUploadAttachmentAction(
      UploadFileArguments argsUpload,
      worker.TypeSendPort sendPort
  ) async {
    try {
      final rootIsolateToken = argsUpload.isolateToken;
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      await HiveCacheConfig.instance.setUp();

      final headerParam = argsUpload.dioClient.getHeaders();
      headerParam[HttpHeaders.contentTypeHeader] = argsUpload.fileInfo.mimeType;
      headerParam[HttpHeaders.contentLengthHeader] = argsUpload.fileInfo.fileSize;

      final mapExtra = <String, dynamic>{
        uploadAttachmentExtraKey: {
          if (argsUpload.fileInfo.filePath?.isNotEmpty == true)
            filePathExtraKey: argsUpload.fileInfo.filePath,
          if (argsUpload.fileInfo.bytes?.isNotEmpty == true)
            streamDataExtraKey: BodyBytesStream.fromBytes(argsUpload.fileInfo.bytes!),
        }
      };

      final resultJson = await argsUpload.dioClient.post(
        Uri.decodeFull(argsUpload.uploadUri.toString()),
        options: Options(
          headers: headerParam,
          extra: mapExtra
        ),
        data: argsUpload.fileInfo.filePath?.isNotEmpty == true
          ? File(argsUpload.fileInfo.filePath!).openRead()
          : argsUpload.fileInfo.bytes != null
              ? BodyBytesStream.fromBytes(argsUpload.fileInfo.bytes!)
              : null,
        onSendProgress: (count, total) {
          log('FileUploader::_handleUploadAttachmentAction():onSendProgress: FILE[${argsUpload.uploadId.id}] : { PROGRESS = $count | TOTAL = $total}');
          sendPort.send(
            UploadingAttachmentUploadState(
              argsUpload.uploadId,
              count,
              argsUpload.fileInfo.fileSize
            )
          );
        }
      );
      log('FileUploader::_handleUploadAttachmentAction(): RESULT_JSON = $resultJson');
      if (argsUpload.fileInfo.mimeType == FileUtils.TEXT_PLAIN_MIME_TYPE) {
        final fileBytes = argsUpload.fileInfo.filePath?.isNotEmpty == true
          ? File(argsUpload.fileInfo.filePath!).readAsBytesSync()
          : argsUpload.fileInfo.bytes;

        final fileCharset = fileBytes != null
          ? await argsUpload.fileUtils.getCharsetFromBytes(fileBytes)
          : null;
        return _parsingResponse(
          resultJson: resultJson,
          fileName: argsUpload.fileInfo.fileName,
          fileCharset: fileCharset?.toLowerCase());
      } else {
        return _parsingResponse(
          resultJson: resultJson,
          fileName: argsUpload.fileInfo.fileName);
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

  Future<Attachment> _handleUploadAttachmentActionOnWeb(
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

    final mapExtra = <String, dynamic>{
      uploadAttachmentExtraKey: {
        if (fileInfo.bytes?.isNotEmpty == true)
          streamDataExtraKey: BodyBytesStream.fromBytes(fileInfo.bytes!),
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
        log('FileUploader::_handleUploadAttachmentActionOnWeb():onSendProgress: FILE[${uploadId.id}] : { PROGRESS = $count | TOTAL = $total}');
        onSendController?.add(
          Right(UploadingAttachmentUploadState(
            uploadId,
            count,
            fileInfo.fileSize
          ))
        );
      }
    );
    log('FileUploader::_handleUploadAttachmentActionOnWeb(): RESULT_JSON = $resultJson');
    if (fileInfo.mimeType == FileUtils.TEXT_PLAIN_MIME_TYPE) {
      final fileCharset = await _fileUtils.getCharsetFromBytes(fileInfo.bytes!);
      return _parsingResponse(
        resultJson: resultJson,
        fileName: fileInfo.fileName,
        fileCharset: fileCharset.toLowerCase());
    } else {
      return _parsingResponse(
        resultJson: resultJson,
        fileName: fileInfo.fileName);
    }
  }

  static Attachment _parsingResponse({
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