import 'package:flutter/material.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';

class AIScribeColors {
  static const textPrimary = AppColor.textPrimary;
  static const background = Colors.white;
  static const svgColorFilter = ColorFilter.mode(
    Color.fromRGBO(66, 66, 68, 0.72),
    BlendMode.srcIn,
  );
}

class AIScribeShadows {
  static List<BoxShadow> get elevation8 => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
}

class AIScribeTextStyles {
  static TextStyle menuItem = ThemeUtils.textStyleBodyBody3(color: AIScribeColors.textPrimary);
  static TextStyle menuHint = ThemeUtils.textStyleBodyBody3(color: AIScribeColors.textPrimary.withValues(alpha: 0.6));
  static TextStyle suggestionTitle = ThemeUtils.textStyleInter700();
  static TextStyle suggestionContent = ThemeUtils.textStyleBodyBody3(color: AIScribeColors.textPrimary);
}

class AIScribeButtonStyles {
  static TextStyle mainActionButtonText = ThemeUtils.textStyleInter500().copyWith(color: AppColor.blue700);
  static const Color mainActionButtonBackgroundColor = Color(0xFFD2E9FF);
  static const EdgeInsetsGeometry mainActionButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16);

  static const Color sendCustomPromptBackgroundColor = AppColor.blue700;
  static const Color sendCustomPromptBackgroundColorDisabled = Color(0xFFD2E9FF);
}

class AIScribeSizes {
  // Border radius
  static const double menuBorderRadius = 12.0;
  static const double menuItemBorderRadius = 6.0;
  static const double scribeButtonBorderRadius = 100.0;

  // Dialog dimensions
  static const double menuWidth = 200.0;
  static const double barWidth = 440.0; 
  static const double modalMaxHeight = 400.0;
  static const double modalMaxWidthLargeScreen = 500.0;
  static const double mobileWidthPercentage = 0.9;
  static const double mobileBreakpoint = 600.0;
  static const double infoHeight = 120.0;

  // Heights
  static const double menuItemHeight = 40.0;
  static const double barHeight = 48.0;
  static const double submenuMaxHeight = 300.0;

  // Spacing
  static const double screenEdgePadding = 16.0;
  static const double submenuSpacing = 6.0;
  static const double fieldSpacing = 8.0;

  // Elevation
  static const double dialogElevation = 8.0;

  // Icon sizes
  static const double iconSize = 18.0;
  static const double sendIconSize = 16.0;
  static const double scribeIconSize = 12.0;

  // Padding (using EdgeInsets)
  static const EdgeInsetsGeometry menuItemPadding = EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 10);
  static const EdgeInsetsGeometry barPadding = EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsetsGeometry suggestionContentPadding = EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsetsGeometry suggestionInfoPadding = EdgeInsets.only(bottom: 16);
  static const EdgeInsetsGeometry suggestionHeaderPadding = EdgeInsets.fromLTRB(16, 8, 8, 8);
  static const EdgeInsetsGeometry suggestionFooterPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  static const EdgeInsetsGeometry scribeButtonPadding = EdgeInsets.all(6);
}
