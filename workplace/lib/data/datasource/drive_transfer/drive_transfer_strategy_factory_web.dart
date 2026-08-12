import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_feature_detection.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_file_ops.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_store.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';

/// Web branch of the conditional export in
/// `drive_transfer_strategy_factory.dart`. Detection and the stale-file sweep
/// are cached per instance, so callers hold one long-lived factory.
class DriveTransferStrategyFactory {
  /// The two seams this factory reaches JS through.
  DriveTransferStrategyFactory({
    OpfsCapability? capability,
    OpfsStore? store,
  })  : _capability = capability ?? OpfsFeatureDetection(),
        _store = store ?? OpfsFileOps();

  final OpfsCapability _capability;
  final OpfsStore _store;

  bool? _opfsSupported;
  bool _swept = false;

  /// [uploader] backs the buffered fallback only; the OPFS strategy uploads
  /// through its own raw-XHR path.
  DriveTransferStrategy<StagedDriveFile> create(
      {required StagedFileUploader uploader}) {
    _opfsSupported ??= _detectOpfsSupport();
    if (!_opfsSupported!) {
      return BufferedWebDriveTransferStrategy(uploader: uploader);
    }
    _sweepStaleTempFilesOnce();
    return OpfsDriveTransferStrategy();
  }

  /// Detection crosses JS interop, so an unexpected browser environment can
  /// throw rather than answer. Treated — and cached — as "not supported".
  bool _detectOpfsSupport() {
    try {
      return _capability.isOpfsSupported();
    } catch (error) {
      logWarning('DriveTransferStrategyFactory: OPFS detection failed: $error');
      return false;
    }
  }

  /// Reclaims OPFS entries orphaned by a tab that died mid-transfer. Fire and
  /// forget, and both failure shapes are swallowed: strategy selection must not
  /// fail over a best-effort cleanup.
  void _sweepStaleTempFilesOnce() {
    if (_swept) return;
    _swept = true;
    try {
      unawaited(_store.sweepStaleTempFiles().catchError((error) {
        logWarning('DriveTransferStrategyFactory: OPFS sweep failed: $error');
      }));
    } catch (error) {
      logWarning('DriveTransferStrategyFactory: OPFS sweep failed: $error');
    }
  }
}
