import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

abstract final class AIScribeColors {
  // Backgrounds
  static const Color background = Colors.white;
  static const Color mainActionButtonBackground = Color(0xFFD2E9FF);
  static const Color sendPromptBackground = AppColor.blue700;
  static const Color sendPromptBackgroundDisabled = Color(0xFFD2E9FF);

  // Icons
  static const Color scribeIcon = AppColor.primaryMain;
  static const Color aiAssistantIcon = AppColor.primaryMain;

  // Overlays
  static final Color dialogBarrier = Colors.black.withValues(alpha: 0.12);
}

abstract final class AIScribeShadows {
  static final List<BoxShadow> sparkleIcon = [
    BoxShadow(
      color: AppColor.gray424244.withValues(alpha: 0.08),
      blurRadius: 3,
      offset: const Offset(0, 1.5),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  static final List<BoxShadow> modal = [
    BoxShadow(
      color: AppColor.gray424244.withValues(alpha: 0.12),
      spreadRadius: 0.5,
    ),
    BoxShadow(
      color: AppColor.gray424244.withValues(alpha: 0.11),
      spreadRadius: 2,
      blurRadius: 26,
      offset: const Offset(0, 6),
    ),
  ];
}

abstract final class AIScribeTextStyles {
  static final TextStyle menuItem = ThemeUtils.textStyleInter400.copyWith(
    fontSize: 14,
    height: 21.01 / 14,
    letterSpacing: -0.15,
    color: AppColor.gray424244.withValues(alpha: 0.9),
  );

  static final TextStyle searchBarHint =
      ThemeUtils.textStyleInter500().copyWith(
    fontSize: 14,
    height: 22 / 14,
    letterSpacing: 0.4,
    color: AppColor.gray9B9B9B.withValues(alpha: 0.85),
  );

  static final TextStyle searchBar = ThemeUtils.textStyleInter400.copyWith(
    fontSize: 14,
    height: 24 / 14,
    letterSpacing: 0.4,
    color: Colors.black.withValues(alpha: 0.85),
  );

  static final TextStyle suggestionTitle =
      ThemeUtils.textStyleInter700().copyWith(
    fontSize: 14,
    height: 22 / 14,
    letterSpacing: 0.4,
    color: AppColor.black1A1A1A.withValues(alpha: 0.85),
  );

  static final TextStyle suggestionLoading =
      ThemeUtils.textStyleInter400.copyWith(
    fontSize: 14,
    height: 22 / 14,
    letterSpacing: 0.4,
    color: AppColor.black1A1A1A.withValues(alpha: 0.85),
  );

  static final TextStyle suggestionContent =
      ThemeUtils.textStyleInter400.copyWith(
    fontSize: 14,
    height: 22 / 14,
    letterSpacing: 0.4,
    color: Colors.black.withValues(alpha: 0.85),
  );

  static final TextStyle mainActionButton =
      ThemeUtils.textStyleInter500().copyWith(
    color: AppColor.blue700,
  );
}

abstract final class AIScribeSizes {
  // Border radius
  static const double menuRadius = 6;
  static const double menuItemRadius = 6;
  static const double searchBarRadius = 10;
  static const double scribeButtonRadius = 100;
  static const double aiAssistantIconRadius = 8;

  // Width / height
  static const double menuItemHeight = 40;
  static const double searchBarMinHeight = 48;
  static const double searchBarMaxHeight = 100;
  static const double searchBarWidth = 405;

  static const double submenuWidth = 191;
  static const double submenuMaxHeight = 352;
  static const double contextMenuWidth = 191;
  static const double contextMenuHeight = 352;

  static const double modalMaxHeight = 256;
  static const double modalMaxWidth = 405;
  static const double suggestionModalMaxWidth = 482;
  static const double suggestionModalMinHeight = 96;
  static const double suggestionModalMaxHeight = 587;

  static const double infoHeight = 120;

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double mobileFactor = 0.9;

  // Spacing
  static const double screenEdgePadding = 16;
  static const double fieldSpacing = 8;
  static const double submenuSpacing = 6;
  static const double modalSpacing = 26;
  static const double modalWithoutContentSpacing = 12;

  // Elevation
  static const double dialogElevation = 8;

  // Icon sizes
  static const double icon = 18;
  static const double sendIcon = 16;
  static const double scribeIcon = 12;
  static const double aiAssistantIcon = 24;

  // Padding
  static const EdgeInsetsGeometry menuItemPadding =
      EdgeInsetsDirectional.only(start: 16, end: 10);

  static const EdgeInsetsGeometry menuCategoryItemPadding =
      EdgeInsetsDirectional.symmetric(horizontal: 14);

  static const EdgeInsetsGeometry searchBarPadding =
      EdgeInsetsDirectional.symmetric(horizontal: 16);

  static const EdgeInsetsGeometry suggestionContentPadding =
      EdgeInsetsDirectional.all(16);

  static const EdgeInsetsGeometry suggestionInfoPadding =
      EdgeInsetsDirectional.only(bottom: 16);

  static const EdgeInsetsGeometry suggestionHeaderPadding =
      EdgeInsetsDirectional.only(start: 16, top: 8, end: 8, bottom: 8);

  static const EdgeInsetsGeometry suggestionFooterPadding =
      EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 16);

  static const EdgeInsetsGeometry scribeButtonPadding =
      EdgeInsetsDirectional.all(6);

  static const EdgeInsetsGeometry mainActionButtonPadding =
      EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);

  static const EdgeInsetsGeometry contextMenuPadding =
      EdgeInsetsDirectional.symmetric(vertical: 8);

  static const EdgeInsetsGeometry aiAssistantIconPadding =
      EdgeInsetsDirectional.all(5);

  static const EdgeInsetsGeometry sendIconPadding =
      EdgeInsetsDirectional.all(8);

  static const EdgeInsetsGeometry backIconPadding =
      EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0);
}
