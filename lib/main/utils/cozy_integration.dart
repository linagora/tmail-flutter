import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:cozy/cozy_config_manager/cozy_config_manager.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

class CozyIntegration {
  const CozyIntegration._();

  static Future<void> integrateCozy() async {
    if (!PlatformInfo.isWeb || !AppConfig.isCozyIntegrationEnabled) return;

    try {
      final cozyConfig = CozyConfigManager();
      await cozyConfig.injectCozyScript();
      await cozyConfig.initialize();
    } catch (e) {
      logError('CozyIntegration::integrateCozy:Exception = $e');
    }
  }
}