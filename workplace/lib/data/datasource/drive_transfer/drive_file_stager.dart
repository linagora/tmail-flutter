import 'package:dio/dio.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';
import 'package:workplace/domain/entity/drive_document.dart';

/// Shared receive timeout for the Dio-backed download legs (IO, web-buffered)
/// — raised from `WorkplaceDio`'s 10s default to tolerate slow-to-first-byte
/// export-on-demand backends (e.g. Cozy) while still catching a stalled
/// mid-transfer connection.
const driveTransferReceiveTimeout = Duration(seconds: 60);

/// Streams a drive document into platform-appropriate temp storage and
/// yields a [StagedDriveFile] ready for upload. One implementation per
/// platform capability (IO, web+OPFS, web-buffered); orchestration is
/// written once against this interface and never branches on platform.
///
/// [T] pins the staged variant an implementation produces, so a stager can
/// only ever be paired with a strategy that can consume its output.
abstract class DriveFileStager<T extends StagedDriveFile> {
  Future<T> stage({
    required DriveDocument doc,
    required OnFileProcessedProgress onDownloadProgress,
    required CancelToken cancelToken,
  });
}
