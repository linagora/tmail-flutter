import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:web/web.dart' as web;
import 'package:model/upload/upload_response.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_xhr_upload.dart';

/// Web-only implementation of [OpfsDriveFileUploader]. Only ever constructed
/// from the web branch of `DriveTransferStrategyFactory`, so this file (and
/// its `package:web` import) never enters an IO/mobile build.
class BrowserOpfsDriveFileUploader implements OpfsDriveFileUploader {
  /// Enough of a text file to identify its encoding; reading it whole would
  /// hand back the memory profile this upload path exists to avoid.
  static const _charsetSniffByteLimit = 64 * 1024;

  final OpfsJsBindings _bindings;
  final FileUtils _fileUtils;

  BrowserOpfsDriveFileUploader({OpfsJsBindings? bindings, FileUtils? fileUtils})
      : _bindings = bindings ?? OpfsJsBindings.instance,
        _fileUtils = fileUtils ?? FileUtils();

  @override
  Future<Attachment> upload(OpfsUploadRequest request) async {
    _throwIfCancelled(request.cancelToken);
    final file = await _bindings.getFile(request.fileHandle);
    _throwIfCancelled(request.cancelToken);
    final charset = await _resolveCharset(file, request.mimeType);
    _throwIfCancelled(request.cancelToken);

    // Cleared in `finally` so the un-unsubscribable `whenCancel` listener
    // below stops holding the XHR once this call is over — `whenCancel` has no
    // removal, and the token can outlive the transfer.
    XhrUploadHandle? activeUpload = _bindings.uploadFile(XhrUploadFileRequest(
      file: file,
      uploadUri: request.uploadUri,
      authHeader: request.authHeader,
      mimeType: request.mimeType,
      onUploadProgress: request.onUploadProgress,
    ));
    final response = activeUpload.response;

    final cancelSubscription = request.cancelToken.whenCancel
        .then((_) => activeUpload?.abort())
        .catchError(
      (error) {
        logWarning('BrowserOpfsDriveFileUploader: failed to abort upload of ${request.fileName}: $error');
      },
    );
    try {
      final json = await response;
      final uploadResponse = UploadResponse.fromJson(json);
      return uploadResponse.toAttachment(
          nameFile: request.fileName, charset: charset);
    } catch (_) {
      // A cancelled token means the user pressed ✕, whatever the abort
      // surfaced as. Makes cancelling after the XHR exists indistinguishable
      // from cancelling before it did (above).
      _throwIfCancelled(request.cancelToken);
      rethrow;
    } finally {
      activeUpload = null;
      unawaited(cancelSubscription);
    }
  }

  /// Only text/plain carries one, the same rule `FileUploader` applies to
  /// attachments picked from disk. Sniffed from a prefix rather than the whole
  /// body; detection failures already fall back to utf-8 inside [FileUtils].
  Future<String?> _resolveCharset(web.File file, String? mimeType) async {
    if (mimeType != FileUtils.TEXT_PLAIN_MIME_TYPE) return null;
    final prefix = await _bindings.readFilePrefix(file, _charsetSniffByteLimit);
    final charset = await _fileUtils.getCharsetFromBytes(prefix);
    return charset.toLowerCase();
  }

  void _throwIfCancelled(CancelToken cancelToken) {
    if (cancelToken.isCancelled) {
      throw cancelToken.cancelError!;
    }
  }
}
