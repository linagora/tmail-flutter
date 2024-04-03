import 'package:core/utils/app_logger.dart';
import 'package:core/utils/web_renderer/canvas_kit.dart';
import 'package:flutter/foundation.dart';

abstract class PlatformInfo {
  static const bool isWeb = kIsWeb;
  static bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  static bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isFuchsia => !kIsWeb && defaultTargetPlatform == TargetPlatform.fuchsia;
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
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
}