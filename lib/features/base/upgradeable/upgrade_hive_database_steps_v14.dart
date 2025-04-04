
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_database_steps.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';

class UpgradeHiveDatabaseStepsV14 extends UpgradeDatabaseSteps {

  final CachingManager _cachingManager;

  UpgradeHiveDatabaseStepsV14(this._cachingManager);

  @override
  Future<void> onUpgrade(int oldVersion, int newVersion) async {
    if (oldVersion > 0 && oldVersion < newVersion && newVersion == 14) {
      await _cachingManager.clearAllEmailAndStateCache();
    }
  }
}