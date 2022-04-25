import 'package:flutter/foundation.dart' as Foundation;

abstract class BuildUtils {
  static const bool isDebugMode = Foundation.kDebugMode;

  static const bool isReleaseMode = Foundation.kReleaseMode;

  static const bool isWeb = Foundation.kIsWeb;

  static const bool isProfileMode = Foundation.kProfileMode;
}