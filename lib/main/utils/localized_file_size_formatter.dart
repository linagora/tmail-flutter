import 'package:intl/intl.dart';

class LocalizedFileSizeFormatter {
  static const int _divider = 1024;
  static const String _fallbackLocale = 'en';

  static const List<String> _englishUnits = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  static const List<String> _frenchUnits = ['o', 'Ko', 'Mo', 'Go', 'To', 'Po'];

  static const Map<String, List<String>> _unitsByLanguageCode = {
    'fr': _frenchUnits,
  };

  const LocalizedFileSizeFormatter._();

  static String format(num bytes, {int fractionDigits = 2, String? locale}) {
    final size = bytes.toInt();
    final resolvedLocale = _resolveLocale(locale ?? Intl.getCurrentLocale());
    final units = _unitsFor(resolvedLocale);

    final unitIndex = _unitIndexFor(size, units.length);
    if (unitIndex == 0) {
      return '$size ${units.first}';
    }

    final unitSize = _pow(_divider, unitIndex);
    final digits = size % unitSize == 0 ? 0 : fractionDigits;
    final value = NumberFormat.decimalPatternDigits(
      locale: resolvedLocale,
      decimalDigits: digits,
    ).format(size / unitSize);
    return '$value ${units[unitIndex]}';
  }

  static int _unitIndexFor(int size, int unitCount) {
    var index = 0;
    var threshold = _divider;
    while (index < unitCount - 1 && size >= threshold) {
      index++;
      threshold *= _divider;
    }
    return index;
  }

  static int _pow(int base, int exponent) =>
      List.filled(exponent, base).fold(1, (result, value) => result * value);

  static String _resolveLocale(String locale) =>
      Intl.verifiedLocale(
        locale,
        NumberFormat.localeExists,
        onFailure: (_) => _fallbackLocale,
      ) ?? _fallbackLocale;

  static List<String> _unitsFor(String locale) =>
      _unitsByLanguageCode[Intl.shortLocale(locale)] ?? _englishUnits;
}
