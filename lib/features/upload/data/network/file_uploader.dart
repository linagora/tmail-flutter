
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/data/network/dio_client.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:model/upload/file_info.dart';
import 'package:model/upload/upload_response.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_body.dart';
import 'package:tmail_ui_user/features/upload/data/network/upload_request_extra.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/upload_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';

class FileUploader {

  /// Charset detection only needs a prefix of the file, so an attachment is
  /// never fully materialised on the root isolate just to sniff its encoding.
  static const int _charsetSampleMaxBytes = 256 * 1024;

  static RequestOptions _sanitizeUploadRequestOptions(RequestOptions requestOptions) {
    final scrubbedExtra = Map<String, dynamic>.from(requestOptions.extra)
      ..remove(UploadRequestExtra.uploadAttachmentKey);
    return requestOptions.copyWith(data: '', extra: scrubbedExtra);
  }

  static DioException _sanitizeUploadException(DioException exception) {
    final scrubbedRequestOptions =
        _sanitizeUploadRequestOptions(exception.requestOptions);
    final response = exception.response;
    return exception.copyWith(
      requestOptions: scrubbedRequestOptions,
      response: response == null
          ? null
          : Response<dynamic>(
              data: response.data,
              requestOptions: scrubbedRequestOptions,
              statusCode: response.statusCode,
              statusMessage: response.statusMessage,
              isRedirect: response.isRedirect,
              redirects: response.redirects,
              extra: response.extra,
              headers: response.headers,
            ),
    );
  }

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

    final body = UploadBody.of(fileInfo);

    try {
      final resultJson = await _dioClient.post(
        Uri.decodeFull(uploadUri.toString()),
        options: Options(
          headers: headerParam,
          extra: body.dioExtra
        ),
        data: body.requestData,
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
        fileCharset: await _resolveCharset(fileInfo, body),
      );
    } on DioException catch (exception) {
      Error.throwWithStackTrace(
        _sanitizeUploadException(exception),
        exception.stackTrace,
      );
    }
  }

  /// Only a text attachment gets its charset probed.
  bool _needsCharsetProbe(FileInfo fileInfo) =>
      fileInfo.mimeType == FileUtils.TEXT_PLAIN_MIME_TYPE;

  /// Reads at most [_charsetSampleMaxBytes] and cancels, so probing a 1 GB
  /// attachment costs one short read, not a second full pass.
  Future<Uint8List?> _readHeadSample(Stream<List<int>> source) async {
    final sample = BytesBuilder();
    await for (final chunk in source) {
      final missing = _charsetSampleMaxBytes - sample.length;
      if (missing <= 0) break;
      sample.add(chunk.length <= missing ? chunk : chunk.sublist(0, missing));
      if (sample.length == _charsetSampleMaxBytes) break;
    }
    return sample.isEmpty ? null : sample.toBytes();
  }

  /// Runs after the server already stored the blob, so a probe failure degrades
  /// to an unknown charset instead of discarding a completed upload.
  Future<String?> _resolveCharset(FileInfo fileInfo, UploadBody body) async {
    if (!_needsCharsetProbe(fileInfo)) {
      return null;
    }

    try {
      // Always read through `body` so the probe samples the same source
      // `UploadBody.of` chose for the request, never a shortcut that can
      // disagree with it.
      final sample = await _readHeadSample(body.open(0, _charsetSampleMaxBytes));
      if (sample == null) {
        return null;
      }

      return (await _fileUtils.getCharsetFromBytes(sample)).toLowerCase();
    } catch (exception) {
      // Only the type: the message of a file error carries the attachment path.
      logWarning('FileUploader::_resolveCharset(): ${exception.runtimeType}');
      return null;
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
      logWarning('FileUploader::_parsingResponse(): DataResponseIsNullException');
      throw const DataResponseIsNullException();
    }
  }
}
