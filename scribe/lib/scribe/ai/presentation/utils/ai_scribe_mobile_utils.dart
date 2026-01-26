import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AiScribeMobileUtils {
  static bool isScribeInMobileMode(BuildContext? context) {
    return context != null && ResponsiveUtils().isMobile(context);
  }
}