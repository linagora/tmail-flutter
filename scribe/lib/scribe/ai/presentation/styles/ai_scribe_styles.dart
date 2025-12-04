import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AIScribeColors {
  static const textPrimary = Color(0xFF1C1B1F);
  static const textSecondary = Color(0xFF49454F);
  static const background = Colors.white;
  static final border = Colors.grey.withValues(alpha: 0.2);
  static const submenuBackground = Colors.white;
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
  static TextStyle menuItem = ThemeUtils.textStyleAIScribeMenuItem();
  static TextStyle suggestionTitle = ThemeUtils.textStyleAIScribeSuggestionTitle();
  static TextStyle suggestionContent = ThemeUtils.textStyleAIScribeSuggestionContent();
}

class AIScribeButtonStyles {
  static TextStyle mainActionButtonText = ThemeUtils.textStyleAIScribeAction(color: AppColor.blue700);
  static const Color mainActionButtonBackgroundColor = Color(0xFFD2E9FF);
  static const EdgeInsetsGeometry mainActionButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16);

  static const Color sendCustomPromptBackgroundColor = AppColor.blue700;
  static const Color sendCustomPromptBackgroundColorDisabled = Color(0xFFD2E9FF);
}

class AIScribeSizes {
  static const double menuItemPadding = 16.0;
  static const double submenuItemPadding = 24.0;
  static const double menuItemVerticalPadding = 12.0;
  static const double menuBorderRadius = 12.0;
  static const double iconSize = 20.0;
}
