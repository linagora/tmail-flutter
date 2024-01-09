
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_database_steps.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';

class UpgradeHiveDatabaseSteps extends UpgradeDatabaseSteps {

  final CachingManager _cachingManager;

  UpgradeHiveDatabaseSteps(this._cachingManager);

  @override
  Future<void> onUpgrade(int oldVersion, int newVersion) async {
    if (oldVersion != newVersion) {
      await _cachingManager.clearData();
    }
  }
}