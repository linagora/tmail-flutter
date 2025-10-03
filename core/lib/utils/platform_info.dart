import 'package:core/utils/app_logger.dart';
import 'package:core/utils/web_renderer/canvas_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as universal_html;

abstract class PlatformInfo {
  @visibleForTesting
  static bool isTestingForWeb = false;
  static bool isIntegrationTesting = false;

  static bool get isWeb => kIsWeb || isTestingForWeb;
  static bool get isLinux =>
      !isWeb && defaultTargetPlatform == TargetPlatform.linux;
  static bool get isWindows =>
      !isWeb && defaultTargetPlatform == TargetPlatform.windows;
  static bool get isMacOS =>
      !isWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isFuchsia =>
      !isWeb && defaultTargetPlatform == TargetPlatform.fuchsia;
  static bool get isIOS =>
      !isWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid =>
      !isWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isLinux || isWindows || isMacOS;
  static bool get isCanvasKit => isRendererCanvasKit;

  static String get platformNameOS {
    var platformName = '';
    if (isWeb) {
      platformName = 'Web';
    } else if (isAndroid) {
      platformName = 'Android';
    } else if (isIOS) {
      platformName = 'IOS';
    } else if (isFuchsia) {
      platformName = 'Fuchsia';
    } else if (isLinux) {
      platformName = 'Linux';
    } else if (isMacOS) {
      platformName = 'MacOS';
    } else if (isWindows) {
      platformName = 'Windows';
    }
    log('PlatformInfo::platformNameOS(): $platformName');
    return platformName;
  }

  static String get userAgent =>
      isWeb ? universal_html.window.navigator.userAgent.toLowerCase() : '';

  /// Web browser on a mobile phone
  static bool get isWebMobile =>
      isWeb && (userAgent.contains('iphone') ||
          (userAgent.contains('android') && userAgent.contains('mobile')));

  /// Web browser on a tablet device
  static bool get isWebTablet =>
      isWeb && (userAgent.contains('ipad') ||
          (userAgent.contains('android') && !userAgent.contains('mobile')));

  /// Web browser on a desktop (PC/Mac)
  static bool get isWebDesktop =>
      isWeb && !isWebMobile && !isWebTablet;

  /// Touch devices
  static bool get isWebTouchDevice =>
      isWeb && (isWebMobile || isWebTablet);
}
