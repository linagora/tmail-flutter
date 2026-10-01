/// Confines untrusted CSS to a subtree of the document by wrapping it into an
/// `@scope (<root>) { ... }` block.
///
/// Wrapping alone is not enough: a stray `}` in the untrusted CSS would close
/// the `@scope` block early and let the following rules apply to the whole
/// document. [scope] therefore tokenizes the CSS following the CSS Syntax
/// Level 3 rules that decide where blocks start and end (comments, strings,
/// escapes, numbers, identifiers and `url(...)` tokens) and neutralizes every
/// `}` that would otherwise close the `@scope` block.
///
/// Browsers without `@scope` support drop the whole block, so the untrusted
/// CSS is ignored rather than leaked.
class CssScopeUtils {
  const CssScopeUtils._();

  /// Returns [css] wrapped into `@scope ([scopeRootSelector]) { ... }`, or an
  /// empty string when [css] cannot be tokenized unambiguously.
  static String scope(String css, String scopeRootSelector) {
    // CSS Syntax 3 §3.3: browsers normalize newlines and NULL before
    // tokenizing, doing it upfront keeps the tokenizer below simple.
    final codeUnits = css
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\f', '\n')
        .replaceAll('\u0000', '�')
        .codeUnits
        .map(_CodeUnit.new)
        .toList();
    final confinedCss = _CssBlockConfiner(codeUnits).confine();
    if (confinedCss == null) {
      return '';
    }
    return '@scope ($scopeRootSelector) {\n$confinedCss\n}';
  }
}

/// A UTF-16 code unit of the stylesheet, [end] past its last one.
extension type const _CodeUnit(int value) implements int {
  static const end = _CodeUnit(-1);
  static const tab = _CodeUnit(0x09);
  static const lineFeed = _CodeUnit(0x0A);
  static const space = _CodeUnit(0x20);
  static const exclamationMark = _CodeUnit(0x21);
  static const doubleQuote = _CodeUnit(0x22);
  static const numberSign = _CodeUnit(0x23);
  static const percent = _CodeUnit(0x25);
  static const singleQuote = _CodeUnit(0x27);
  static const openParenthesis = _CodeUnit(0x28);
  static const closeParenthesis = _CodeUnit(0x29);
  static const asterisk = _CodeUnit(0x2A);
  static const plus = _CodeUnit(0x2B);
  static const hyphen = _CodeUnit(0x2D);
  static const fullStop = _CodeUnit(0x2E);
  static const slash = _CodeUnit(0x2F);
  static const lessThan = _CodeUnit(0x3C);
  static const questionMark = _CodeUnit(0x3F);
  static const at = _CodeUnit(0x40);
  static const upperE = _CodeUnit(0x45);
  static const upperU = _CodeUnit(0x55);
  static const openBracket = _CodeUnit(0x5B);
  static const backslash = _CodeUnit(0x5C);
  static const closeBracket = _CodeUnit(0x5D);
  static const underscore = _CodeUnit(0x5F);
  static const lowerE = _CodeUnit(0x65);
  static const lowerU = _CodeUnit(0x75);
  static const openBrace = _CodeUnit(0x7B);
  static const closeBrace = _CodeUnit(0x7D);

  static const Map<_CodeUnit, _CodeUnit> closingOf = {
    openBrace: closeBrace,
    openParenthesis: closeParenthesis,
    openBracket: closeBracket,
  };

  bool get isDigit => value >= 0x30 && value <= 0x39;

  bool get isHexDigit =>
      isDigit || (value >= 0x41 && value <= 0x46) || (value >= 0x61 && value <= 0x66);

  bool get isNameStart =>
      (value >= 0x61 && value <= 0x7A) || (value >= 0x41 && value <= 0x5A) || this == underscore || value >= 0x80;

  bool get isName => isNameStart || isDigit || this == hyphen;

  bool get isWhitespace => this == lineFeed || this == space || this == tab;

  bool get isQuote => this == doubleQuote || this == singleQuote;

  bool get isSign => this == plus || this == hyphen;
}

/// The next code units of the stylesheet, as CSS Syntax 3 §4.3 inspects them
/// to decide which token starts here.
class _Lookahead {
  final _CodeUnit first;
  final _CodeUnit second;
  final _CodeUnit third;
  final _CodeUnit fourth;

  const _Lookahead(this.first, this.second, this.third, this.fourth);

  _Lookahead get next => _Lookahead(second, third, fourth, _CodeUnit.end);

  bool get startsComment => first == _CodeUnit.slash && second == _CodeUnit.asterisk;

  /// `<!--` is a single CDO token: reading it as `<`, `!` and an identifier
  /// `--url` would miss that a following `url(` starts a url token.
  bool get startsCdo =>
      first == _CodeUnit.lessThan
          && second == _CodeUnit.exclamationMark
          && third == _CodeUnit.hyphen
          && fourth == _CodeUnit.hyphen;

  bool get isValidEscape =>
      first == _CodeUnit.backslash && second != _CodeUnit.end && second != _CodeUnit.lineFeed;

  /// `#name` (hash token) or `@name` (at-keyword token).
  bool get startsPrefixedName {
    if (first == _CodeUnit.numberSign) {
      return second.isName || next.isValidEscape;
    }
    return first == _CodeUnit.at && next.startsIdentifier;
  }

  bool get startsIdentifier {
    if (first == _CodeUnit.hyphen) {
      return second.isNameStart || second == _CodeUnit.hyphen || next.isValidEscape;
    }
    return first.isNameStart || isValidEscape;
  }

  bool get startsNumber {
    if (first.isSign) {
      return second.isDigit || (second == _CodeUnit.fullStop && third.isDigit);
    }
    if (first == _CodeUnit.fullStop) {
      return second.isDigit;
    }
    return first.isDigit;
  }

  bool get startsExponent {
    if (first != _CodeUnit.lowerE && first != _CodeUnit.upperE) {
      return false;
    }
    return second.isDigit || (second.isSign && third.isDigit);
  }

  bool get startsUnicodeRange =>
      (first == _CodeUnit.lowerU || first == _CodeUnit.upperU)
          && second == _CodeUnit.plus
          && (third.isHexDigit || third == _CodeUnit.questionMark);
}

class _CssBlockConfiner {
  static const int _maxHexDigits = 6;
  static const int _replacementCharacter = 0xFFFD;

  final List<_CodeUnit> _codeUnits;
  final List<_CodeUnit> _expectedClosings = [];
  int _index = 0;

  _CssBlockConfiner(this._codeUnits);

  _CodeUnit get _current => _index < _codeUnits.length ? _codeUnits[_index] : _CodeUnit.end;

  _Lookahead get _lookahead {
    _CodeUnit at(int offset) =>
        _index + offset < _codeUnits.length ? _codeUnits[_index + offset] : _CodeUnit.end;
    return _Lookahead(at(0), at(1), at(2), at(3));
  }

  String? confine() {
    while (_index < _codeUnits.length) {
      if (!_consumeToken()) {
        return null;
      }
    }
    return String.fromCharCodes(_codeUnits);
  }

  /// Consumes the next token, returns false when it is ambiguous.
  bool _consumeToken() {
    final lookahead = _lookahead;

    if (lookahead.startsComment) {
      _skipComment();
    } else if (lookahead.startsCdo) {
      _index += 4;
    } else if (lookahead.first.isQuote) {
      _skipString(lookahead.first);
    } else if (lookahead.startsPrefixedName) {
      _index++;
      _consumeName();
    } else if (lookahead.startsNumber) {
      _skipNumeric();
    } else if (lookahead.startsUnicodeRange) {
      return _skipUnicodeRange();
    } else if (lookahead.startsIdentifier) {
      _skipIdentLike();
    } else {
      _consumeDelimiter(lookahead.first);
    }
    return true;
  }

  /// Tracks nested blocks and neutralizes any `}` that would close the
  /// enclosing `@scope` block.
  void _consumeDelimiter(_CodeUnit current) {
    final closing = _CodeUnit.closingOf[current];
    if (closing != null) {
      _expectedClosings.add(closing);
    } else if (_isExpectedClosing(current)) {
      _expectedClosings.removeLast();
    } else if (_isUnmatchedCloseBrace(current)) {
      _codeUnits[_index] = _CodeUnit.space;
    }
    _index++;
  }

  bool _isExpectedClosing(_CodeUnit codeUnit) =>
      _expectedClosings.isNotEmpty && _expectedClosings.last == codeUnit;

  bool _isUnmatchedCloseBrace(_CodeUnit codeUnit) =>
      codeUnit == _CodeUnit.closeBrace && _expectedClosings.isEmpty;

  bool get _isValidEscapeHere => _current == _CodeUnit.backslash && _lookahead.isValidEscape;

  void _skipComment() {
    _index += 2;
    while (_index < _codeUnits.length) {
      if (_current == _CodeUnit.asterisk && _lookahead.second == _CodeUnit.slash) {
        _index += 2;
        return;
      }
      _index++;
    }
  }

  /// An unterminated string ends, unconsumed, at the next newline.
  void _skipString(_CodeUnit quote) {
    _index++;
    while (_index < _codeUnits.length) {
      final current = _current;
      if (current == quote) {
        _index++;
        return;
      }
      if (current == _CodeUnit.lineFeed) {
        return;
      }
      if (current == _CodeUnit.backslash) {
        _skipStringEscape();
      } else {
        _index++;
      }
    }
  }

  /// A hex escape also swallows one whitespace, even a newline, so the string
  /// does not end there (`"\a` + newline + `}` keeps the `}` in the string).
  void _skipStringEscape() {
    _index++;
    if (_current.isHexDigit) {
      _consumeEscape();
    } else {
      _index++;
    }
  }

  void _skipNumeric() {
    if (_current.isSign) {
      _index++;
    }
    _skipDigits();
    if (_current == _CodeUnit.fullStop && _lookahead.second.isDigit) {
      _index++;
      _skipDigits();
    }
    final lookahead = _lookahead;
    if (lookahead.startsExponent) {
      _index += lookahead.second.isDigit ? 1 : 2;
      _skipDigits();
    }
    if (_lookahead.startsIdentifier) {
      _consumeName();
    } else if (_current == _CodeUnit.percent) {
      _index++;
    }
  }

  void _skipDigits() {
    while (_current.isDigit) {
      _index++;
    }
  }

  /// Some browsers (Chromium) tokenize `U+...` as a unicode-range token,
  /// others (Firefox) as an identifier followed by other tokens. Both agree
  /// on where it ends unless a name code point immediately follows, in which
  /// case the CSS is rejected as ambiguous.
  bool _skipUnicodeRange() {
    _index += 2;
    _skipUnicodeRangeStart();
    if (_current == _CodeUnit.hyphen && _lookahead.second.isHexDigit) {
      _index++;
      _skipHexDigits();
    }
    return !_current.isName && _current != _CodeUnit.backslash;
  }

  void _skipUnicodeRangeStart() {
    int length = _skipHexDigits();
    while (length < _maxHexDigits && _current == _CodeUnit.questionMark) {
      _index++;
      length++;
    }
  }

  /// Skips up to six hex digits, returns how many were skipped.
  int _skipHexDigits() {
    int length = 0;
    while (length < _maxHexDigits && _current.isHexDigit) {
      _index++;
      length++;
    }
    return length;
  }

  /// An identifier spelling `url` followed by `(` and an unquoted argument
  /// forms a single url token: braces, quotes and comments inside it are
  /// not interpreted.
  void _skipIdentLike() {
    final name = _consumeName();
    if (_current != _CodeUnit.openParenthesis || name.toLowerCase() != 'url') {
      return;
    }

    final openParenthesisIndex = _index;
    _index++;
    while (_current.isWhitespace) {
      _index++;
    }
    if (_current.isQuote) {
      _index = openParenthesisIndex;
      return;
    }
    _skipUrlArgument();
  }

  /// Valid or not, an unquoted url token always ends at the first unescaped
  /// `)` or at the end of the stylesheet.
  void _skipUrlArgument() {
    while (_index < _codeUnits.length) {
      if (_current == _CodeUnit.closeParenthesis) {
        _index++;
        return;
      }
      _index += _isValidEscapeHere ? 2 : 1;
    }
  }

  String _consumeName() {
    final name = StringBuffer();
    while (_index < _codeUnits.length) {
      final current = _current;
      if (_isValidEscapeHere) {
        _index++;
        name.writeCharCode(_consumeEscape());
      } else if (current.isName) {
        name.writeCharCode(current);
        _index++;
      } else {
        break;
      }
    }
    return name.toString();
  }

  /// Consumes what follows a `\`, returns the escaped code point.
  int _consumeEscape() {
    final hexStart = _index;
    while (_index - hexStart < _maxHexDigits && _current.isHexDigit) {
      _index++;
    }

    if (_index == hexStart) {
      return _codeUnits[_index++];
    }

    final codePoint = int.parse(String.fromCharCodes(_codeUnits.sublist(hexStart, _index)), radix: 16);
    if (_current.isWhitespace) {
      _index++;
    }
    return codePoint.isValidEscapedCodePoint ? codePoint : _replacementCharacter;
  }
}

extension on int {
  bool get isValidEscapedCodePoint => this != 0 && this <= 0x10FFFF && (this < 0xD800 || this > 0xDFFF);
}
