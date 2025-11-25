import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AIScribeColors {
  static const textPrimary = Color(0xFF1C1B1F);
  static const textSecondary = Color(0xFF49454F);
  static const background = Colors.white;
  static final border = Colors.grey.withValues(alpha: 0.2);
  static final submenuBackground = Colors.grey.withValues(alpha: 0.05);
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
  static const menuItem = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AIScribeColors.textPrimary,
  );

  static const submenuItem = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AIScribeColors.textPrimary,
  );

  static TextStyle resultContent = ThemeUtils.textStyleAIScribeSuggestion(
    color: AIScribeColors.textPrimary,
  );
}

class AIScribeSizes {
  static const double menuItemPadding = 16.0;
  static const double submenuItemPadding = 24.0;
  static const double menuItemVerticalPadding = 12.0;
  static const double menuBorderRadius = 12.0;
  static const double iconSize = 20.0;
}
