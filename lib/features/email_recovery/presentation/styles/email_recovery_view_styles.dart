import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class EmailRecoveryViewStyles {
  static const BoxDecoration backgroundDecorationMobile = BoxDecoration(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    color: Colors.white,
  );
  static const BoxDecoration backgroundDecorationDesktop = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(16)),
    color: Colors.white,
  );

  static EdgeInsetsGeometry backgroundMarginMobile = EdgeInsets.only(top: PlatformInfo.isWeb ? 70 : 0);

  static const BorderRadiusGeometry clipRRectBorderRadiusMobile = BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
  );
  static const BorderRadiusGeometry clipRRectBorderRadiusDesktop = BorderRadius.all(Radius.circular(16));

  static const ShapeBorder shapeBorderDesktop = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
}