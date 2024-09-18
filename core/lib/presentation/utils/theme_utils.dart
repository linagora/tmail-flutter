import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeUtils {

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
        thickness: WidgetStateProperty.all(8.0),
        radius: const Radius.circular(8.0),
        thumbColor: WidgetStateProperty.all(AppColor.thumbScrollbarColor)),
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      bodyMedium: TextStyle(color: AppColor.baseTextColor),
      bodySmall: TextStyle(color: AppColor.baseTextColor),
    );
  }

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