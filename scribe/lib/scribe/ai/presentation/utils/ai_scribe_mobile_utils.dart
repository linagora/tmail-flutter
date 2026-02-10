import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiScribeMobileUtils {
  static bool isScribeInMobileMode(BuildContext? context) {
    return context != null && Get.find<ResponsiveUtils>().isMobile(context);
  }
}