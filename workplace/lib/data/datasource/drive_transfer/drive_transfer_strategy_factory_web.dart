import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';
import 'package:workplace/data/datasource/drive_transfer/staged_drive_file.dart';
import 'package:workplace/data/model/workplace_type_defs.dart';

/// Web branch of the conditional export in
/// `drive_transfer_strategy_factory.dart`: OPFS detection runs once per
/// session and is cached (module-level field), so repeated `create()` calls
/// across a batch never re-probe.
class DriveTransferStrategyFactory {
  const DriveTransferStrategyFactory._();

  static bool? _opfsSupported;
  static bool _swept = false;

  /// [uploader] backs the buffered fallback only; the OPFS strategy uploads
  /// through its own raw-XHR path.
  static DriveTransferStrategy<StagedDriveFile> create(
      {required StagedFileUploader uploader}) {
    _opfsSupported ??= _detectOpfsSupport();
    if (!_opfsSupported!) {
      return BufferedWebDriveTransferStrategy(uploader: uploader);
    }
    _sweepStaleTempFilesOnce();
    return OpfsDriveTransferStrategy();
  }

  /// Detection crosses JS interop, so an unexpected browser environment can
  /// throw rather than answer. That is treated as "not supported" — and cached
  /// as such, so a failure doesn't re-probe and re-throw on every later call.
  static bool _detectOpfsSupport() {
    try {
      return OpfsJsBindings.instance.isOpfsSupported();
    } catch (error) {
      logWarning('DriveTransferStrategyFactory: OPFS detection failed: $error');
      return false;
    }
  }

  /// Reclaims OPFS entries orphaned by a tab that died mid-transfer. Fire and
  /// forget: it only touches entries hours older than anything this session
  /// creates, so no transfer waits on it — or fails with it.
  ///
  /// Both failure shapes are swallowed: `catchError` for a rejected future, and
  /// the try/catch for a binding that throws before it returns one. Strategy
  /// selection must not fail over a best-effort cleanup.
  static void _sweepStaleTempFilesOnce() {
    if (_swept) return;
    _swept = true;
    try {
      unawaited(
          OpfsJsBindings.instance.sweepStaleTempFiles().catchError((error) {
        logWarning('DriveTransferStrategyFactory: OPFS sweep failed: $error');
      }));
    } catch (error) {
      logWarning('DriveTransferStrategyFactory: OPFS sweep failed: $error');
    }
  }

  @visibleForTesting
  static void resetCache() {
    _opfsSupported = null;
    _swept = false;
  }
}
