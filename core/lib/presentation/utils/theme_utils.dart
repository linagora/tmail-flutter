import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linagora_design_flutter/style/linagora_text_theme.dart';

class ThemeUtils {
  ThemeUtils._();

  static ThemeData buildAppTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: _designSystemFontFamily,
      fontFamilyFallback: ConstantsUI.fontFamilyFallback,
      appBarTheme: _appBarTheme,
      textTheme: _textTheme,
      extensions: [_textThemeExtension],
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

  /// Resolved from the design system rather than named here, so that changing
  /// the font in `linagora_design_flutter` is enough to change it in the app.
  static final String? _designSystemFontFamily =
      LinagoraTextTheme.material().bodyMedium?.fontFamily;

  static final TextTheme _textTheme = _buildTextTheme();

  static final LinagoraTextThemeExtension _textThemeExtension =
      _buildTextThemeExtension();

  /// Design system styles are built with `package: linagora_design_flutter`,
  /// and [TextStyle.fontFamilyFallback] prefixes every entry it returns with
  /// `packages/<package>/`. Passing our fallback list straight to a design
  /// system style would therefore point it at families the design system does
  /// not ship, silently disabling the whole fallback chain (emoji, Arabic,
  /// CJK...). Rebuilding the style without a package keeps the chain intact.
  ///
  /// Drop this once the design system accepts a `fontFamilyFallback`:
  /// https://github.com/linagora/linagora-design-flutter/issues/78
  static TextStyle? _withFallback(TextStyle? style) {
    if (style == null) return null;
    return _withFallbackRequired(style);
  }

  @visibleForTesting
  static TextStyle withFallbackForTesting(TextStyle style) =>
      _withFallbackRequired(style);

  static TextStyle _withFallbackRequired(TextStyle style) {
    return TextStyle(
      inherit: style.inherit,
      fontFamily: style.fontFamily,
      fontFamilyFallback: ConstantsUI.fontFamilyFallback,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      fontStyle: style.fontStyle,
      letterSpacing: style.letterSpacing,
      wordSpacing: style.wordSpacing,
      textBaseline: style.textBaseline,
      height: style.height,
      leadingDistribution: style.leadingDistribution,
      locale: style.locale,
      color: style.color,
      backgroundColor: style.backgroundColor,
      foreground: style.foreground,
      background: style.background,
      shadows: style.shadows,
      fontFeatures: style.fontFeatures,
      fontVariations: style.fontVariations,
      decoration: style.decoration,
      decorationColor: style.decorationColor,
      decorationStyle: style.decorationStyle,
      decorationThickness: style.decorationThickness,
      overflow: style.overflow,
    );
  }

  static TextTheme _buildTextTheme() {
    final textTheme = LinagoraTextTheme.material();
    return TextTheme(
      displayLarge: _withFallback(textTheme.displayLarge),
      displayMedium: _withFallback(textTheme.displayMedium),
      displaySmall: _withFallback(textTheme.displaySmall),
      headlineLarge: _withFallback(textTheme.headlineLarge),
      headlineMedium: _withFallback(textTheme.headlineMedium),
      headlineSmall: _withFallback(textTheme.headlineSmall),
      titleLarge: _withFallback(textTheme.titleLarge),
      titleMedium: _withFallback(textTheme.titleMedium),
      titleSmall: _withFallback(textTheme.titleSmall),
      labelLarge: _withFallback(textTheme.labelLarge),
      labelMedium: _withFallback(textTheme.labelMedium),
      labelSmall: _withFallback(textTheme.labelSmall),
      bodyLarge: _withFallback(textTheme.bodyLarge),
      bodyMedium: _withFallback(textTheme.bodyMedium),
      bodySmall: _withFallback(textTheme.bodySmall),
    );
  }

  static LinagoraTextThemeExtension _buildTextThemeExtension() {
    final extension = LinagoraTextThemeExtension.material();
    return LinagoraTextThemeExtension(
      titleSemibold: _withFallbackRequired(extension.titleSemibold),
      titleSmall2: _withFallbackRequired(extension.titleSmall2),
      bodyLargeBold: _withFallbackRequired(extension.bodyLargeBold),
      bodyLarge1: _withFallbackRequired(extension.bodyLarge1),
      bodyLarge2: _withFallbackRequired(extension.bodyLarge2),
      bodyMedium1: _withFallbackRequired(extension.bodyMedium1),
      bodyMedium2: _withFallbackRequired(extension.bodyMedium2),
      bodyMedium3: _withFallbackRequired(extension.bodyMedium3),
      bodyMedium4: _withFallbackRequired(extension.bodyMedium4),
    );
  }

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

  static TextStyle get textStyleM3TitleSmall => defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontSize: 14,
    height: 20 / 14,
    color: AppColor.m3Tertiary20,
  );

  static TextStyle get textStyleM3TitleMedium => defaultTextStyleInterFont.copyWith(
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

  /// Carries only the design system font, so the legacy `textStyle*` helpers
  /// below keep their own metrics while following the design system font.
  /// Each helper should eventually read from [_textTheme] instead.
  static TextStyle defaultTextStyleInterFont = TextStyle(
    fontFamily: _designSystemFontFamily,
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
    backgroundColor: Colors.white,
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