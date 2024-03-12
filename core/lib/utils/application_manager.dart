
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApplicationManager {

  final DeviceInfoPlugin _deviceInfoPlugin;

  ApplicationManager(this._deviceInfoPlugin);

  Future<PackageInfo> getPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    log('ApplicationManager::getPackageInto: $packageInfo');
    return packageInfo;
  }

  Future<String> getVersion() async {
    final version = (await getPackageInfo()).version;
    log('ApplicationManager::getVersion: $version');
    return version;
  }

  Future<String> getUserAgent() async {
    try {
      String userAgent = '';
      if (PlatformInfo.isWeb) {
        final webBrowserInfo = await _deviceInfoPlugin.webBrowserInfo;
        userAgent = webBrowserInfo.userAgent ?? '';
      } else if (PlatformInfo.isMobile) {
        userAgent = FkUserAgent.userAgent ?? '';
      }
      log('ApplicationManager::getUserAgent: $userAgent');
      return userAgent;
    } catch(e) {
      logError('ApplicationManager::getUserAgent: Exception: $e');
      return '';
    }
  }

  Future<void> initUserAgent() async {
    if (PlatformInfo.isMobile) {
      await FkUserAgent.init();
    }
  }

  Future<void> releaseUserAgent() async {
    if (PlatformInfo.isMobile) {
      FkUserAgent.release();
    }
  }

  Future<String> generateApplicationUserAgent() async {
    final userAgent = await getUserAgent();
    final version = await getVersion();
    return 'Twake-Mail/$version $userAgent';
  }
}