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
  Future<Attachment> upload(OpfsUploadRequest request);
}

/// Bundles [OpfsDriveFileUploader.upload]'s parameters to keep its argument
/// count low.
class OpfsUploadRequest {
  final OpfsFileHandle fileHandle;
  final String fileName;
  final Uri uploadUri;
  final String authHeader;
  final String? mimeType;
  final OnFileProcessedProgress onUploadProgress;
  final CancelToken cancelToken;

  const OpfsUploadRequest({
    required this.fileHandle,
    required this.fileName,
    required this.uploadUri,
    required this.authHeader,
    required this.mimeType,
    required this.onUploadProgress,
    required this.cancelToken,
  });
}
