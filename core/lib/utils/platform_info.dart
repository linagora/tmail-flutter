import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';

abstract class PlatformInfo {
  static const bool isWeb = kIsWeb;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isLinux || isWindows || isMacOS;

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