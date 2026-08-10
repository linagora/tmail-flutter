import 'package:dio/dio.dart';
import 'package:model/email/attachment.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/domain/entity/drive_document.dart';

/// Both legs of a drive transfer for one platform capability, selected once
/// per batch via `DriveTransferStrategyFactory.create()`. Orchestration —
/// stage, upload, dispose — never branches on platform.
abstract class DriveTransferStrategy {
  Future<StagedDriveFile> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  });

  Future<Attachment> upload(DriveUploadRequest request);
}

/// Bundles [DriveTransferStrategy.upload]'s parameters to keep its argument
/// count low.
class DriveUploadRequest {
  final StagedDriveFile staged;
  final Uri uploadUri;

  /// Only used by the OPFS raw-XHR path; the other strategies authenticate
  /// through the app's Dio interceptors.
  final String authHeader;

  final OnFileProcessedProgress onUploadProgress;
  final CancelToken cancelToken;

  const DriveUploadRequest({
    required this.staged,
    required this.uploadUri,
    required this.authHeader,
    required this.onUploadProgress,
    required this.cancelToken,
  });
}
