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

  /// [authHeader] is only used by the OPFS raw-XHR path; the others
  /// authenticate through the app's Dio interceptors.
  Future<Attachment> upload({
    required StagedDriveFile staged,
    required Uri uploadUri,
    required String authHeader,
    required OnFileProcessedProgress onUploadProgress,
    required CancelToken cancelToken,
  });
}
