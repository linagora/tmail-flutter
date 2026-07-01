import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:model/model.dart';

/// Visual configuration for `TwpWarningBanner`, centralised in one place
/// (matching the project's `*_banner_style.dart` convention) so layout metrics
/// and the per-level palette live outside the widget and can be unit-tested.
///
/// Background + accent (icon) colors reuse [AppColor] tokens for consistency
/// with the rest of the app. Border and text colors are tuned locally because
/// [AppColor] has no soft-border / readable on-container text tokens (the bright
/// accent colors are unreadable as text on the light tints). The app ships no
/// dark theme, so there are no dark variants.
class TwpWarningBannerStyle {
  const TwpWarningBannerStyle._();

  static const EdgeInsetsGeometry margin = EdgeInsetsDirectional.symmetric(
    vertical: 6,
    horizontal: 16,
  );
  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(
    vertical: 5,
    horizontal: 12,
  );
  static const double borderRadius = 10;
  static const double iconSize = 20;
  static const double iconSpacing = 10;
  static const double messageFontSize = 14;
  static const double messageLineHeight = 1.35;
  static const double dismissSpacing = 4;
  static const double dismissIconSize = 18;
  static const EdgeInsets dismissPadding = EdgeInsets.all(6);

  /// Resolves the color/icon palette for a warning [level].
  static TwpWarningLevelStyle ofLevel(TwpWarningLevel level) {
    switch (level) {
      case TwpWarningLevel.error:
        return _error;
      case TwpWarningLevel.warn:
        return _warn;
      case TwpWarningLevel.info:
        return _info;
    }
  }

  static const _error = TwpWarningLevelStyle(
    backgroundColor: AppColor.colorBackgroundErrorState,
    borderColor: Color(0xFFF5C6C0),
    textColor: Color(0xFF8B1A10),
    iconColor: AppColor.colorErrorState,
    icon: Icons.dangerous_outlined,
  );

  static const _warn = TwpWarningLevelStyle(
    backgroundColor: AppColor.colorBackgroundNotificationVacationSetting,
    borderColor: Color(0xFFF3E0A6),
    textColor: Color(0xFF7A5A00),
    iconColor: AppColor.warningColor,
    icon: Icons.warning_amber_rounded,
  );

  static const _info = TwpWarningLevelStyle(
    backgroundColor: AppColor.primarySelectedColor,
    borderColor: Color(0xFFBBD6FB),
    textColor: Color(0xFF0B4A8F),
    iconColor: AppColor.primaryColor,
    icon: Icons.info_outline,
  );
}

/// Color + icon palette for a single [TwpWarningLevel].
class TwpWarningLevelStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final IconData icon;

  const TwpWarningLevelStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.icon,
  });
}
