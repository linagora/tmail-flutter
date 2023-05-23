import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class PlatformInfo {
  static bool get isWeb => kIsWeb;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isLinux || isWindows || isMacOS;
}