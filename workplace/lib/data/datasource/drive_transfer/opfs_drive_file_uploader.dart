import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_handle.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';

/// Uploads an OPFS-staged file via a raw-XHR POST that streams straight from
/// the OPFS-backed file without materializing it in the JS heap — the only
/// upload path `FileUploader` can't do. Not refresh-and-retry safe: the
/// bearer token is read once, up front.
///
/// Held privately by the OPFS strategy, not exposed on
/// `DriveTransferStrategy`.
abstract class OpfsDriveFileUploader {
  Future<Attachment> upload({
    required OpfsFileHandle fileHandle,
    required String fileName,
    required String? mimeType,
    required Uri uploadUri,
    required String authHeader,
    required OnFileProcessedProgress onUploadProgress,
    required CancelToken cancelToken,
  });
}
