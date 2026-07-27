import 'package:workplace/data/datasource/drive_transfer/drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_uploader.dart';

/// Bundles the stager for a platform capability plus, for web+OPFS, the
/// raw-XHR uploader — the only upload path that can't reuse `FileUploader`.
/// Selected once per batch via `DriveTransferStrategyFactory.create()`.
abstract class DriveTransferStrategy {
  DriveFileStager get stager;

  /// Non-null only for the OPFS strategy.
  OpfsDriveFileUploader? get opfsUploader;
}
