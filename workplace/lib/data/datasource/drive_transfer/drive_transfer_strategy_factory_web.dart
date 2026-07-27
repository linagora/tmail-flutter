import 'package:flutter/foundation.dart';
import 'package:workplace/data/datasource/drive_transfer/buffered_web_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_drive_file_stager.dart';
import 'package:workplace/data/datasource/drive_transfer/opfs_js_bindings.dart';

/// Web branch of the conditional export in
/// `drive_transfer_strategy_factory.dart`: OPFS detection runs once per
/// session and is cached (module-level field), so repeated `create()` calls
/// across a batch never re-probe.
class DriveTransferStrategyFactory {
  const DriveTransferStrategyFactory._();

  static bool? _opfsSupported;

  static DriveTransferStrategy create() {
    _opfsSupported ??= OpfsJsBindings.instance.isOpfsSupported();
    return _opfsSupported!
        ? OpfsDriveTransferStrategy()
        : BufferedWebDriveTransferStrategy();
  }

  @visibleForTesting
  static void resetCache() => _opfsSupported = null;
}
