import 'package:core/utils/platform_info.dart';

class ConstantsUI {
  static const String fontApp = 'TwakeInter';
  static const String fontFileRegular = '$fontApp-Regular';
  static const String fontFileMedium = '$fontApp-Medium';
  static const String fontFileSemiBold = '$fontApp-SemiBold';
  static const String fontFileBold = '$fontApp-Bold';

  static final List<String>? fontFamilyFallback = PlatformInfo.isMobile
      ? null
      : webFontFamilyFallback;

  static const List<String> webFontFamilyFallback = [
    'Roboto', // Default Flutter font – Latin, Cyrillic, Diacritics
    'NotoSans', // Latin, Cyrillic – supports European languages
    'NotoSansArabic', // Arabic script
    'NotoSansTamil', // Tamil script
    'NotoSansThai', // Thai script
    'NotoSansKR', // Korean
    'NotoSansSC', // Simplified Chinese (zh_Hans)
    'NotoSansMath', // Math symbols (∑, ∫, √, etc.)
    'NotoSansEgyptianHieroglyphs', // Egyptian Hieroglyphs (𓀀)
    'NotoEmoji', // Monochrome emoji
    'NotoSansSymbols', // Miscellaneous symbols and arrows
    'NotoSansSymbols2', // Extended symbol support
    'sans-serif', // Generic fallback for any platform
  ];

  static const double htmlContentMaxHeight = 22000.0;
  static const double composerHtmlContentMaxHeight = 20000.0;
  static const double htmlContentMinWidth = 300;
  static const double htmlContentMinHeight = 150;
  static const double htmlContentOffsetHeight = 30.0;
}