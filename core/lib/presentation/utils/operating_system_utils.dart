import 'dart:io';

class OperatingSystemUtils {

  static bool isLinux() {
    return Platform.isLinux;
  }

  static bool isWindow() {
    return Platform.isWindows;
  }

  static bool isMacOS() {
    return Platform.isMacOS;
  }

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool isFuchsia() {
    return Platform.isFuchsia;
  }

  static bool isDesktop() {
    return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  }
}