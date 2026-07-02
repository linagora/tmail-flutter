import 'package:equatable/equatable.dart';

const String twpMessageHeaderName = 'X-TWP-Message';

enum TwpWarningLevel {
  info,
  warn,
  error;

  static TwpWarningLevel parse(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'warn':
        return TwpWarningLevel.warn;
      case 'error':
        return TwpWarningLevel.error;
      case 'info':
        return TwpWarningLevel.info;
      default:
        return TwpWarningLevel.info;
    }
  }
}

class TwpWarning with EquatableMixin {
  static const String defaultCode = 'unknown';
  static const String _levelPrefix = 'level:';
  static const String _codePrefix = 'code:';

  final TwpWarningLevel level;
  final String code;
  final String fallbackText;
  final int index;

  const TwpWarning({
    required this.level,
    required this.code,
    required this.fallbackText,
    required this.index,
  });

  factory TwpWarning.parse(String raw, int index) {
    var remainder = raw.trim();
    TwpWarningLevel level = TwpWarningLevel.info;
    String code = defaultCode;

    if (remainder.startsWith(_levelPrefix)) {
      final afterLevel = remainder.substring(_levelPrefix.length);
      final spaceIndex = afterLevel.indexOf(' ');
      final levelToken = spaceIndex == -1 ? afterLevel : afterLevel.substring(0, spaceIndex);
      level = TwpWarningLevel.parse(levelToken);
      remainder = spaceIndex == -1 ? '' : afterLevel.substring(spaceIndex + 1).trimLeft();
    }

    if (remainder.startsWith(_codePrefix)) {
      final afterCode = remainder.substring(_codePrefix.length);
      final spaceIndex = afterCode.indexOf(' ');
      final codeToken = spaceIndex == -1 ? afterCode : afterCode.substring(0, spaceIndex);
      code = codeToken.trim().isEmpty ? defaultCode : codeToken.trim();
      remainder = spaceIndex == -1 ? '' : afterCode.substring(spaceIndex + 1).trimLeft();
    }

    return TwpWarning(
      level: level,
      code: code,
      fallbackText: remainder.trim(),
      index: index,
    );
  }

  TwpWarning copyWithIndex(int newIndex) {
    return TwpWarning(
      level: level,
      code: code,
      fallbackText: fallbackText,
      index: newIndex,
    );
  }

  @override
  List<Object?> get props => [level, code, fallbackText, index];
}

List<TwpWarning> deduplicateTwpWarnings(List<TwpWarning> parsed) {
  final seen = <String>{};
  final deduplicated = <TwpWarning>[];

  for (final warning in parsed) {
    final key = '${warning.level.name}|${warning.code}|${warning.fallbackText}';
    if (seen.add(key)) {
      deduplicated.add(warning);
    }
  }

  return [
    for (var i = 0; i < deduplicated.length; i++) deduplicated[i].copyWithIndex(i),
  ];
}
