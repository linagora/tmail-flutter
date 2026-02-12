import 'package:flutter/foundation.dart';

/// Checks the current platform paradigm
class PlatformInfo {
  /// Checks if the app is currently running on iOS or macOS
  static final bool isCupertino =
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
}
