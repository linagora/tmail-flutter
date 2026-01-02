import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApplicationManager {
  ApplicationManager._internal();

  static final ApplicationManager _instance = ApplicationManager._internal();

  factory ApplicationManager() => _instance;

  @visibleForTesting
  static DeviceInfoPlugin? debugDeviceInfoOverride;

  DeviceInfoPlugin get _deviceInfo =>
      debugDeviceInfoOverride ?? DeviceInfoPlugin();

  PackageInfo? _packageInfoCache;
  String? _versionCache;
  String? _cachedWebUserAgent;
  String? _cachedMobileUserAgent;
  bool _isMobileUserAgentInitialized = false;

  @visibleForTesting
  void clearCache() {
    _packageInfoCache = null;
    _versionCache = null;
    _cachedWebUserAgent = null;
    _cachedMobileUserAgent = null;
  }

  Future<PackageInfo> getPackageInfo() async {
    if (_packageInfoCache != null) {
      return _packageInfoCache!;
    }

    final info = await PackageInfo.fromPlatform();
    _packageInfoCache = info;

    log('ApplicationManager:getPackageInfo -> cached: $info');
    return info;
  }

  Future<String> getAppVersion() async {
    if (_versionCache != null) {
      return _versionCache!;
    }

    try {
      final version = (await getPackageInfo()).version;
      _versionCache = version;

      log('ApplicationManager:getAppVersion -> cached: $version');
      return version;
    } catch (e) {
      logWarning('ApplicationManager:getAppVersion failedd, Exception = $e');
      return '';
    }
  }

  Future<void> initUserAgent() async {
    if (!PlatformInfo.isMobile) return;

    try {
      await FkUserAgent.init();
      _isMobileUserAgentInitialized = true;
      _cachedMobileUserAgent = null;

      log('ApplicationManager:initUserAgent -> initialized');
    } catch (e) {
      logWarning('ApplicationManager:initUserAgent failed, Exception $e');
    }
  }

  Future<void> releaseUserAgent() async {
    if (!PlatformInfo.isMobile) return;

    try {
      FkUserAgent.release();
      _isMobileUserAgentInitialized = false;
      _cachedMobileUserAgent = null;

      log('ApplicationManager:releaseUserAgent -> released & cache cleared');
    } catch (e) {
      logWarning('ApplicationManager:releaseUserAgent failed, Exception $e');
    }
  }

  Future<String> getUserAgent() async {
    try {
      if (PlatformInfo.isWeb) {
        return _getWebUserAgent();
      }

      if (PlatformInfo.isMobile) {
        return _getMobileUserAgent();
      }

      return '';
    } catch (e) {
      logWarning('ApplicationManager:getUserAgent failed');
      return '';
    }
  }

  Future<String> _getWebUserAgent() async {
    if (_cachedWebUserAgent != null) {
      return _cachedWebUserAgent!;
    }

    WebBrowserInfo webInfo;

    try {
      webInfo = await _deviceInfo.webBrowserInfo;
    } catch (e) {
      logWarning('ApplicationManager:_getWebUserAgent failed, Exception $e');
      return '';
    }

    final userAgent = webInfo.userAgent ?? '';
    _cachedWebUserAgent = userAgent;

    log('ApplicationManager:_getWebUserAgent -> cached');
    return userAgent;
  }

  Future<String> _getMobileUserAgent() async {
    if (!_isMobileUserAgentInitialized) {
      logWarning(
        'ApplicationManager:_getMobileUserAgent called before initUserAgent',
      );
      return '';
    }

    if (_cachedMobileUserAgent != null) {
      return _cachedMobileUserAgent!;
    }

    final userAgent = FkUserAgent.userAgent;

    if (userAgent == null || userAgent.isEmpty) {
      return '';
    }

    _cachedMobileUserAgent = userAgent;
    log('ApplicationManager:_getMobileUserAgent -> cached');

    return userAgent;
  }

  Future<String> generateApplicationUserAgent() async {
    final version = await getAppVersion();
    final userAgent = await getUserAgent();

    return 'Twake-Mail/$version $userAgent'.trim();
  }
}
