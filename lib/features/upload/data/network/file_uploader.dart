
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  /// Charset detection only needs a prefix of the file, so an attachment is
  /// never fully materialised on the root isolate just to sniff its encoding.
  static const int _charsetSampleMaxBytes = 256 * 1024;

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

  /// Web has no `dart:io` file system, so an attachment there is always
  /// uploaded from its bytes even if a path happens to be carried along.
  bool _hasLocalFilePath(FileInfo fileInfo) =>
      !PlatformInfo.isWeb && fileInfo.filePath?.isNotEmpty == true;

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

  Stream<List<int>> _buildRequestBody(FileInfo fileInfo) {
    if (_hasLocalFilePath(fileInfo)) {
      return File(fileInfo.filePath!).openRead();
    }
    final bytes = fileInfo.bytes;
    if (bytes == null) {
      throw const MissingAttachmentSourceException();
    }
    return BodyBytesStream.fromBytes(bytes);
  }

  /// Runs after the server already stored the blob, so a probe failure degrades
  /// to an unknown charset instead of discarding a completed upload.
  Future<String?> _resolveCharset(FileInfo fileInfo) async {
    if (fileInfo.mimeType != FileUtils.TEXT_PLAIN_MIME_TYPE) {
      return null;
    }

    try {
      final Uint8List? charsetSample;
      if (_hasLocalFilePath(fileInfo)) {
        charsetSample = await _readCharsetSample(fileInfo.filePath!);
      } else {
        final bytes = fileInfo.bytes;
        charsetSample = bytes != null && bytes.length > _charsetSampleMaxBytes
            ? Uint8List.sublistView(bytes, 0, _charsetSampleMaxBytes)
            : bytes;
      }
      if (charsetSample == null) {
        return null;
      }

      return (await _fileUtils.getCharsetFromBytes(charsetSample)).toLowerCase();
    } catch (exception) {
      // Only the type: the message of a file error carries the attachment path.
      logWarning('FileUploader::_resolveCharset(): ${exception.runtimeType}');
      return null;
    }
  }

  Future<Uint8List> _readCharsetSample(String filePath) async {
    final sample = BytesBuilder(copy: false);
    await for (final chunk in File(filePath).openRead(0, _charsetSampleMaxBytes)) {
      sample.add(chunk);
    }
    return sample.takeBytes();
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
