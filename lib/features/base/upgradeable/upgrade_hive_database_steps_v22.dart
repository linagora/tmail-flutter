import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_database_steps.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';

class UpgradeHiveDatabaseStepsV22 extends UpgradeDatabaseSteps {
  final CachingManager _cachingManager;

  UpgradeHiveDatabaseStepsV22(this._cachingManager);

  @override
  Future<void> onUpgrade(int oldVersion, int newVersion) async {
    if (_shouldUpgrade(oldVersion, newVersion)) {
      await _cachingManager.clearDetailedEmailCache();
    }
  }

  bool _shouldUpgrade(int oldVersion, int newVersion) =>
    oldVersion > 0 &&
    oldVersion < newVersion &&
    newVersion == 22 &&
    PlatformInfo.isMobile;
}
