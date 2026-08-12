import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:web/web.dart' as web;
import 'package:model/upload/upload_response.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_ops.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_store.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_xhr_upload.dart';

/// Web-only implementation of [OpfsDriveFileUploader]. Only ever constructed
/// from the web branch of `DriveTransferStrategyFactory`, so this file (and
/// its `package:web` import) never enters an IO/mobile build.
class BrowserOpfsDriveFileUploader implements OpfsDriveFileUploader {
  /// Enough of a text file to identify its encoding; reading it whole would
  /// hand back the memory profile this upload path exists to avoid.
  static const _charsetSniffByteLimit = 64 * 1024;

  final OpfsStore _store;
  final DriveUploadTransport _transport;
  final FileUtils _fileUtils;

  BrowserOpfsDriveFileUploader({
    OpfsStore? store,
    DriveUploadTransport? transport,
    FileUtils? fileUtils,
  })  : _store = store ?? OpfsFileOps(),
        _transport = transport ?? OpfsXhrUpload(),
        _fileUtils = fileUtils ?? FileUtils();

  /// Everything from opening the staged entry to parsing the response sits
  /// inside the one `try`, because each leg throws something a caller
  /// branching on [DioExceptionType] cannot classify — `getFile` a bare
  /// `DOMException` when the entry has gone, the decode a `TypeError` on a
  /// body that parsed but doesn't match. They are classified apart, though:
  /// only the decode is the server's fault, so it shapes its own
  /// [DioExceptionType.badResponse] in [_parseUploadResponse] and the rest
  /// falls through to [_asDioFailure].
  @override
  Future<Attachment> upload(OpfsUploadRequest request) async {
    _throwIfCancelled(request.cancelToken);

    // Cleared in `finally` so the un-unsubscribable `whenCancel` listener
    // below stops holding the XHR once this call is over — `whenCancel` has no
    // removal, and the token can outlive the transfer.
    XhrUploadHandle? activeUpload;
    Future<void>? cancelSubscription;
    try {
      final file = await _store.getFile(request.fileHandle);
      _throwIfCancelled(request.cancelToken);

      // Runs alongside the transfer: nothing the upload sends depends on the
      // charset. Not `Future.wait`, whose `ParallelWaitError` would hide the
      // [DioException] callers branch on.
      final charsetFuture = _resolveCharset(file, request.mimeType);

      activeUpload = _transport.uploadFile(XhrUploadFileRequest(
        file: file,
        uploadUri: request.uploadUri,
        authHeader: request.authHeader,
        mimeType: request.mimeType,
        onUploadProgress: request.onUploadProgress,
      ));
      final response = activeUpload.response;

      cancelSubscription = request.cancelToken.whenCancel
          .then((_) => activeUpload?.abort())
          .catchError(
        (error) {
          logWarning('BrowserOpfsDriveFileUploader: failed to abort upload of ${request.fileName}: $error');
        },
      );

      final uploadResponse =
          _parseUploadResponse(await response, request.uploadUri);
      return uploadResponse.toAttachment(
          nameFile: request.fileName, charset: await charsetFuture);
    } catch (e) {
      // A cancelled token means the user pressed ✕, whatever the abort
      // surfaced as. Makes cancelling after the XHR exists indistinguishable
      // from cancelling before it did.
      _throwIfCancelled(request.cancelToken);
      throw _asDioFailure(e, request.uploadUri);
    } finally {
      activeUpload = null;
      if (cancelSubscription != null) unawaited(cancelSubscription);
    }
  }

  /// The one failure on this path that really is the response's: a 2xx whose
  /// JSON parsed but doesn't match the upload schema. Classified here rather
  /// than in [_asDioFailure] so that catch-all doesn't have to guess a type it
  /// cannot know — a `TypeError` off the decode and a `DOMException` off the
  /// OPFS read arrive there indistinguishable.
  UploadResponse _parseUploadResponse(
    Map<String, dynamic> body,
    Uri uploadUri,
  ) {
    try {
      return UploadResponse.fromJson(body);
    } catch (e) {
      throw DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: uploadUri.toString()),
        error: e,
        message: 'the drive upload response could not be parsed',
      );
    }
  }

  /// [OpfsXhrUpload] already shapes every transport failure and
  /// [_parseUploadResponse] the decode, so what reaches here is the OPFS read
  /// and anything else unforeseen — browser errors with no HTTP meaning.
  /// [DioExceptionType.unknown] is what that is, the same call
  /// `OpfsDriveFileStager._asDioFailure` makes for its own OPFS leg; claiming
  /// `badResponse` would point callers at a server that answered fine.
  Object _asDioFailure(Object error, Uri uploadUri) {
    if (error is DioException) return error;
    return DioException(
      type: DioExceptionType.unknown,
      requestOptions: RequestOptions(path: uploadUri.toString()),
      error: error,
      message: 'the drive upload could not be completed',
    );
  }

  /// Only text/plain carries one, the same rule `FileUploader` applies to
  /// attachments picked from disk. Sniffed from a prefix rather than the whole
  /// body; detection failures already fall back to utf-8 inside [FileUtils].
  Future<String?> _resolveCharset(web.File file, String? mimeType) async {
    if (mimeType != FileUtils.TEXT_PLAIN_MIME_TYPE) return null;
    try {
      final prefix = await _store.readFilePrefix(file, _charsetSniffByteLimit);
      return (await _fileUtils.getCharsetFromBytes(prefix)).toLowerCase();
    } catch (e) {
      logWarning('BrowserOpfsDriveFileUploader: charset sniff failed: $e');
      // Same outcome as a non-text file: an upload is not worth failing over a
      // header the server can infer.
      return null;
    }
  }

  void _throwIfCancelled(CancelToken cancelToken) {
    if (cancelToken.isCancelled) {
      throw cancelToken.cancelError!;
    }
  }
}
