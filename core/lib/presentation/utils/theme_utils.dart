import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeUtils {
  ThemeUtils._();

  static ThemeData buildAppTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: ConstantsUI.fontApp,
      fontFamilyFallback: ConstantsUI.fontFamilyFallback,
      appBarTheme: _appBarTheme,
      textTheme: _textTheme,
      hoverColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
      textSelectionTheme: _textSelectionTheme,
      dividerTheme: _dividerTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(6.0),
        radius: const Radius.circular(10.0),
        thumbColor: WidgetStateProperty.all(AppColor.thumbScrollbarColor)),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    bodyLarge: TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: -0.15,
      fontSize: 17,
      height: 24 / 17,
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      fontSize: 13,
      height: 16 / 13
    ),
    labelLarge: TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelSmall: TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    displayLarge: TextStyle(
      fontWeight: FontWeight.w700,
    ),
    displayMedium: TextStyle(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
    displaySmall: TextStyle(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 24,
      height: 32 / 24,
      letterSpacing: 0.0,
    ),
    headlineLarge: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 32,
    ),
    titleLarge: TextStyle(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
      fontSize: 22,
      height: 28 / 22,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      fontSize: 16,
      height: 24 / 16,
    ),
    titleSmall: TextStyle(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      fontSize: 14,
      height: 20 / 14,
    ),
  );

  static TextStyle textStyleBodyBody1({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: fontSize ?? 16,
    height: 20 / (fontSize ?? 16),
    color: color,
  );

  static TextStyle textStyleBodyBody2({
    Color? color,
    Color? backgroundColor,
    FontWeight? fontWeight,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: fontWeight ?? FontWeight.w400,
    letterSpacing: 0.0,
    fontSize: 15,
    height: 20 / 15,
    color: color,
    backgroundColor: backgroundColor,
  );

  static TextStyle textStyleBodyBody3({
    Color? color,
    FontWeight? fontWeight,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: fontWeight ?? FontWeight.w400,
    letterSpacing: 0.0,
    fontSize: 14,
    height: 18 / 14,
    color: color,
  );

  static TextStyle textStyleBodyContact({
    Color? color,
    Color? backgroundColor,
    FontWeight? fontWeight,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: fontWeight ?? FontWeight.w600,
    letterSpacing: 0.0,
    fontSize: 15,
    height: 20 / 15,
    color: color,
    backgroundColor: backgroundColor,
  );

  static TextStyle textStyleBodySmallHeadline = defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.13,
    fontSize: 13,
    height: 16 / 13,
    color: Colors.black,
  );

  static TextStyle textStyleHeadingH6({
    Color? color,
    FontWeight? fontWeight,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: fontWeight ?? FontWeight.w700,
    letterSpacing: 0.0,
    fontSize: 20,
    height: 24 / 20,
    color: color,
  );

  static TextStyle textStyleHeadingH5({
    Color? color,
    FontWeight? fontWeight,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: 24,
    height: 28 / 24,
    color: color,
  );

  static TextStyle textStyleHeadingH4({
    Color? color,
    FontWeight? fontWeight,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: 32,
    height: 40 / 32,
    color: color,
  );

  static TextStyle textStyleHeadingHeadingSmall({
    Color? color,
    FontWeight? fontWeight,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: 17,
    height: 22 / 17,
    color: color,
  );

  static TextStyle textStyleM3HeadlineSmall = defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    fontSize: 24,
    height: 32 / 24,
    color: AppColor.m3SurfaceBackground,
  );

  static TextStyle textStyleInter700({
    Color? color,
    double? fontSize,
  }) => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    fontSize: fontSize ?? 15,
    height: 20 / (fontSize ?? 15),
    color: color ?? Colors.black,
  );

  static TextStyle textStyleInter500() => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: 14,
    height: 18 / 14,
    color: Colors.black,
  );

  static final TextStyle textStyleInter400 = defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.normal,
    letterSpacing: -0.13,
    fontSize: 13,
    height: 16 / 13,
    color: Colors.black,
  );

  static TextStyle textStyleM3LabelLarge({Color? color}) => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontSize: 14,
    height: 20 / 14,
    color: color ?? AppColor.primaryMain,
  );

  static TextStyle get textStyleM3LabelSmall => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontSize: 11,
    height: 16 / 11,
    color: AppColor.m3Tertiary,
  );

  static TextStyle get textStyleM3LabelMedium => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontSize: 12,
    height: 16 / 12,
    color: AppColor.m3Tertiary30,
  );

  static TextStyle get textStyleM3TitleSmall => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontSize: 14,
    height: 20 / 14,
    color: AppColor.m3Tertiary20,
  );

  static TextStyle get textStyleM3TitleMedium => defaultTextStyleInterFont.copyWith(
    fontFamily: ConstantsUI.fontApp,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    fontSize: 16,
    height: 24 / 16,
    color: AppColor.secondaryContrastText,
  );

  static TextStyle textStyleM3BodyMedium1 = defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w400,
    letterSpacing: -0.15,
    fontSize: 16,
    height: 24 / 16,
    color: AppColor.textPrimary,
  );

  static TextStyle textStyleM3BodyMedium3 = defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    fontSize: 14,
    height: 20 / 14,
    color: AppColor.m3SurfaceBackground,
  );

  static final TextStyle textStyleM3BodyMedium = defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    fontSize: 14,
    height: 20 / 14,
    color: AppColor.textSecondary.withValues(alpha: 0.48),
  );

  static TextStyle textStyleM3BodyLarge = defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: -0.15,
    fontSize: 17,
    height: 24 / 17,
    color: AppColor.m3SurfaceBackground,
  );

  static TextStyle textStyleAppShortcut() => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.normal,
    letterSpacing: 0.0,
    fontSize: 12,
    height: 22.5 / 12,
    color: AppColor.textPrimary,
  );

  static TextStyle textStyleContentCaption() => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    fontSize: 11,
    height: 14 / 11,
    color: AppColor.steelGray400,
  );

  static TextStyle textStyleInter600() => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    fontSize: 24,
    height: 28.01 / 24,
    color: AppColor.gray424244.withValues(alpha: 0.9),
  );

  static TextStyle defaultTextStyleInterFont = TextStyle(
    fontFamily: ConstantsUI.fontApp,
    fontFamilyFallback: ConstantsUI.fontFamilyFallback,
  );

  static TextSelectionThemeData get _textSelectionTheme {
    return const TextSelectionThemeData(
      cursorColor: AppColor.primaryColor,
      selectionHandleColor: AppColor.primaryColor,
      selectionColor: AppColor.primarySelectedColor,
    );
  }

  static final AppBarTheme _appBarTheme = AppBarTheme(
    color: Colors.white,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    iconTheme: const IconThemeData(color: Colors.black),
    titleTextStyle: defaultTextStyleInterFont.copyWith(
      color: const Color(0XFF8B8B8B),
      fontSize: 18,
    ),
    toolbarTextStyle: defaultTextStyleInterFont,
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColor.colorDivider,
    space: 0
  );

  static void setSystemLightUIStyle() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  static void setSystemDarkUIStyle() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  static void setStatusBarTransparentColor() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }
}