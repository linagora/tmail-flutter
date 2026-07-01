import 'package:equatable/equatable.dart';
import 'package:model/email/twp_warning/twp_warning_level.dart';

/// A warning the backend positions on a message via an `X-TWP-Message` header.
///
/// Format — `level:` and `code:` are optional leading tokens; the rest is
/// server-provided fallback text, used when [code] cannot be localized:
/// ```
/// X-TWP-Message: level:info code:suspicious-sender This email is from an external sender.
/// ```
class TwpWarning with EquatableMixin {
  static const String _levelToken = 'level:';
  static const String _codeToken = 'code:';

  /// Hoisted so the pattern is compiled once, not on every [parse] call.
  static final RegExp _whitespace = RegExp(r'\s+');

  final TwpWarningLevel level;
  final String? code;
  final String fallbackText;

  /// Position of this warning among the `X-TWP-Message` headers of the message
  /// (0-based). Used to persist a per-warning dismissal keyword.
  final int index;

  TwpWarning({
    required this.level,
    required this.code,
    required this.fallbackText,
    required this.index,
  });

  /// Parses a raw `X-TWP-Message` header value into a [TwpWarning].
  ///
  /// Tolerant of missing `level:` / `code:` tokens; everything that is not a
  /// recognized leading token is kept as the [fallbackText].
  factory TwpWarning.parse(String rawValue, int index) {
    String? level;
    String? code;
    final remainingTokens = <String>[];

    var parsingTokens = true;
    for (final token in rawValue.trim().split(_whitespace)) {
      if (parsingTokens && token.toLowerCase().startsWith(_levelToken)) {
        level = token.substring(_levelToken.length);
      } else if (parsingTokens && token.toLowerCase().startsWith(_codeToken)) {
        code = token.substring(_codeToken.length);
      } else {
        parsingTokens = false;
        remainingTokens.add(token);
      }
    }

    final trimmedCode = code?.trim();

    return TwpWarning(
      level: TwpWarningLevel.fromValue(level),
      code: trimmedCode?.isNotEmpty == true ? trimmedCode : null,
      fallbackText: remainingTokens.join(' '),
      index: index,
    );
  }

  @override
  List<Object?> get props => [level, code, fallbackText, index];
}
