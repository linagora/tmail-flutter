import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';

/// Uploads an OPFS-staged file via a raw-XHR POST that streams straight from
/// the OPFS-backed file without materializing it in the JS heap — the only
/// upload path `FileUploader` can't do. Not refresh-and-retry safe: the
/// bearer token is read once, up front.
///
/// Declared without any `dart:js_interop`/`package:web` reference so this
/// file stays part of the platform-agnostic `DriveTransferStrategy` surface;
/// [fileHandle] is an opaque `web.FileSystemFileHandle`. The concrete
/// `BrowserOpfsDriveFileUploader` (web-only, `opfs_drive_file_uploader_web.dart`)
/// is the only place that casts it back.
abstract class OpfsDriveFileUploader {
  Future<Attachment> upload({
    required Object fileHandle,
    required String fileName,
    required String? mimeType,
    required Uri uploadUri,
    required String authHeader,
    required void Function(int sent, int total) onUploadProgress,
    required CancelToken cancelToken,
  });
}
