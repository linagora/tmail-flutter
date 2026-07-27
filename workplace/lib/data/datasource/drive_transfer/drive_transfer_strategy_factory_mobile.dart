import 'package:workplace/data/datasource/drive_transfer/drive_transfer_strategy.dart';
import 'package:workplace/data/datasource/drive_transfer/io_drive_file_stager.dart';

/// Mobile/desktop branch of the conditional export in
/// `drive_transfer_strategy_factory.dart`: always IO temp-file staging.
class DriveTransferStrategyFactory {
  const DriveTransferStrategyFactory._();

  static DriveTransferStrategy create() => IoDriveTransferStrategy();
}
