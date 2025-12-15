import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApplicationManager {
  static final ApplicationManager _instance = ApplicationManager._internal();

  factory ApplicationManager() => _instance;

  ApplicationManager._internal();

  // Allow overriding in unit tests
  @visibleForTesting
  static DeviceInfoPlugin? debugDeviceInfoOverride;

  DeviceInfoPlugin get _deviceInfoPlugin =>
      debugDeviceInfoOverride ?? DeviceInfoPlugin();

  Future<PackageInfo> getPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    log('ApplicationManager::getPackageInto: $packageInfo');
    return packageInfo;
  }

  Future<String> getVersion() async {
    try {
      final version = (await getPackageInfo()).version;
      log('ApplicationManager::getVersion: $version');
      return version;
    } catch (e) {
      return '';
    }
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
      logWarning('ApplicationManager::getUserAgent: Exception: $e');
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