import 'package:flutter/material.dart';
import 'package:core/presentation/extensions/color_extension.dart';

/// Tokens from the TF-4827 Figma frames (web 9929-5510, mobile 12004-18682).
class DriveOversizeUploadDialogStyle {
  const DriveOversizeUploadDialogStyle._();

  // Colours the design system has no token for.
  static const Color titleColor = Color(0xE6424244);      // rgba(66,66,68,.9)
  static const Color separatorColor = Color(0x1F424244);  // rgba(66,66,68,.12)
  static const Color secondaryTextColor = Color(0xFF737373);
  static const Color chipBorderColor = Color(0xFFE5ECF3);
  static const Color fileNameColor = Color(0xFF1C1B1F);
  static const Color barTrackColor = Color(0xFFD9D9D9);
  // The bar fill and Cancel label are #0A84FF == AppColor.primaryColor.

  static const double webSurfaceRadius = 6;
  static const double mobileSurfaceRadius = 14;
  static const double webMaxWidth = 629;
  static const double maxListHeight = 264;   // ~4 rows before it scrolls

  static const double chipWidth = 191;
  static const double chipRadius = 8;
  static const double thumbnailSize = 20;
  static const double thumbnailRadius = 2;
  static const double barHeight = 6;
  static const double barRadius = 26;
  static const double rowCloseButtonSize = 40;
  static const double rowCloseIconSize = 16;
  static const double headerCloseIconSize = 24;
  static const double webBarWidth = 157;
  static const double mobileBarInset = 24;
  static const double webSizeLabelWidth = 68;
  static const double mobileSizeLabelWidth = 45;

  static const EdgeInsetsGeometry headerPadding =
      EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsetsGeometry descriptionPadding =
      EdgeInsetsDirectional.only(start: 16, end: 24, bottom: 8);
  static const EdgeInsetsGeometry rowPadding =
      EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsetsGeometry chipPadding = EdgeInsets.all(8);
  static const EdgeInsetsGeometry cancelPadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 10);

  static const List<BoxShadow> surfaceShadow = [
    BoxShadow(color: Color(0x3D424244), offset: Offset(0, 12), blurRadius: 16, spreadRadius: -8),
    BoxShadow(color: Color(0x3D424244), offset: Offset(0, 12), blurRadius: 48, spreadRadius: 8),
    BoxShadow(color: Color(0x1F424244), blurRadius: 0, spreadRadius: 0.5),
  ];

  static const TextStyle webTitle = TextStyle(
      fontSize: 24, height: 28 / 24, fontWeight: FontWeight.w600, color: titleColor);
  static const TextStyle mobileTitle = TextStyle(
      fontSize: 16, height: 21 / 16, fontWeight: FontWeight.w600,
      letterSpacing: 0.15, color: titleColor);
  static const TextStyle webBody = TextStyle(
      fontSize: 16, height: 20 / 16, fontWeight: FontWeight.w500, color: secondaryTextColor);
  static const TextStyle mobileBody = TextStyle(
      fontSize: 13, height: 16 / 13, fontWeight: FontWeight.w400, color: secondaryTextColor);
  /// The emphasised run inside the description ("a link").
  static const TextStyle emphasisedBody = TextStyle(color: Color(0xFF0C0C0C));
  static const TextStyle fileNameTextStyle = TextStyle(
      fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500,
      letterSpacing: 0.1, color: fileNameColor);
  static const TextStyle cancelTextStyle = TextStyle(
      fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500,
      letterSpacing: 0.1, color: AppColor.primaryColor);

  static TextStyle title(bool isWeb) => isWeb ? webTitle : mobileTitle;
  static TextStyle body(bool isWeb) => isWeb ? webBody : mobileBody;
  static TextStyle sizeText(bool isWeb) => isWeb ? webBody : mobileBody;
  static double sizeLabelWidth(bool isWeb) =>
      isWeb ? webSizeLabelWidth : mobileSizeLabelWidth;
}
