import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeUtils {
  ThemeUtils._();

  static ThemeData get appTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: ConstantsUI.fontApp,
      appBarTheme: _appBarTheme,
      textTheme: _textTheme,
      textSelectionTheme: _textSelectionTheme,
      dividerTheme: _dividerTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(6.0),
        radius: const Radius.circular(10.0),
        thumbColor: WidgetStateProperty.all(AppColor.thumbScrollbarColor)),
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.15,
        fontSize: 17,
        height: 24 / 17,
      ),
      bodyMedium: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        fontSize: 13,
        height: 16 / 13
      ),
      labelLarge: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelSmall: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      displayLarge: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      displaySmall: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      headlineMedium: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      headlineLarge: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w600,
        fontSize: 32,
      ),
      titleLarge: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        fontSize: 22,
        height: 28 / 22,
      ),
      titleMedium: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: ConstantsUI.fontApp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
    );
  }

  static TextStyle textStyleBodyBody1({
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: fontSize ?? 16,
    height: (height ?? 20) / (fontSize ?? 16),
    color: color,
  );

  static TextStyle textStyleBodyBody2({
    Color? color,
    Color? backgroundColor,
    FontWeight? fontWeight,
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
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
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
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
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
    fontWeight: fontWeight ?? FontWeight.w600,
    letterSpacing: 0.0,
    fontSize: 15,
    height: 20 / 15,
    color: color,
    backgroundColor: backgroundColor,
  );

  static TextStyle textStyleHeadingH6({
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
    fontWeight: fontWeight ?? FontWeight.w700,
    letterSpacing: 0.0,
    fontSize: 20,
    height: (height ?? 24) / 20,
    color: color,
  );

  static TextStyle textStyleHeadingH5({
    Color? color,
    FontWeight? fontWeight,
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: 24,
    height: 28 / 24,
    color: color,
  );

  static TextStyle textStyleHeadingH4({
    Color? color,
    FontWeight? fontWeight,
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: 32,
    height: 40 / 32,
    color: color,
  );

  static TextStyle textStyleHeadingHeadingSmall({
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
    fontWeight: fontWeight ?? FontWeight.w500,
    letterSpacing: 0.0,
    fontSize: 17,
    height: (height ?? 22) / 17,
    color: color,
  );

  static TextStyle textStyleInter700({
    Color? color,
    double? fontSize,
  }) => TextStyle(
    fontFamily: ConstantsUI.fontApp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    fontSize: fontSize ?? 15,
    height: 20 / (fontSize ?? 15),
    color: color,
  );

  static TextSelectionThemeData get _textSelectionTheme {
    return const TextSelectionThemeData(
      cursorColor: AppColor.primaryColor,
      selectionHandleColor: AppColor.primaryColor,
      selectionColor: AppColor.primarySelectedColor,
    );
  }

  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      color: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    );
  }

  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColor.colorDivider,
      space: 0
    );
  }

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