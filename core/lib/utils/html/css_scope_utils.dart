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

  static const int _tab = 0x09;
  static const int _lineFeed = 0x0A;
  static const int _space = 0x20;
  static const int _doubleQuote = 0x22;
  static const int _numberSign = 0x23;
  static const int _percent = 0x25;
  static const int _singleQuote = 0x27;
  static const int _openParenthesis = 0x28;
  static const int _closeParenthesis = 0x29;
  static const int _asterisk = 0x2A;
  static const int _plus = 0x2B;
  static const int _hyphen = 0x2D;
  static const int _fullStop = 0x2E;
  static const int _slash = 0x2F;
  static const int _questionMark = 0x3F;
  static const int _at = 0x40;
  static const int _upperE = 0x45;
  static const int _upperU = 0x55;
  static const int _openBracket = 0x5B;
  static const int _backslash = 0x5C;
  static const int _closeBracket = 0x5D;
  static const int _underscore = 0x5F;
  static const int _lowerE = 0x65;
  static const int _lowerU = 0x75;
  static const int _openBrace = 0x7B;
  static const int _closeBrace = 0x7D;
  static const int _replacementCharacter = 0xFFFD;

  static const int _maxHexDigitsInEscape = 6;
  static const int _maxHexDigitsInUnicodeRange = 6;

  static const Map<int, int> _closingOf = {
    _openBrace: _closeBrace,
    _openParenthesis: _closeParenthesis,
    _openBracket: _closeBracket,
  };

  /// Returns [css] wrapped into `@scope ([scopeRootSelector]) { ... }`, or an
  /// empty string when [css] cannot be tokenized unambiguously.
  static String scope(String css, String scopeRootSelector) {
    final confinedCss = _CssBlockConfiner(_preprocess(css)).confine();
    if (confinedCss == null) {
      return '';
    }
    return '@scope ($scopeRootSelector) {\n$confinedCss\n}';
  }

  /// CSS Syntax 3 §3.3: browsers normalize newlines and NULL before
  /// tokenizing, doing it upfront keeps the tokenizer below simple.
  static List<int> _preprocess(String css) {
    return css
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\f', '\n')
        .replaceAll('\u0000', '�')
        .codeUnits
        .toList();
  }
}

class _CssBlockConfiner {
  final List<int> _codeUnits;
  final List<int> _expectedClosings = [];
  int _index = 0;

  _CssBlockConfiner(this._codeUnits);

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
    final current = _codeUnits[_index];

    if (current == CssScopeUtils._slash && _at(_index + 1) == CssScopeUtils._asterisk) {
      _skipComment();
    } else if (current == CssScopeUtils._doubleQuote || current == CssScopeUtils._singleQuote) {
      _skipString(current);
    } else if (current == CssScopeUtils._numberSign && _isHashStart(_index + 1)) {
      _index++;
      _consumeName();
    } else if (current == CssScopeUtils._at && _wouldStartIdentifier(_index + 1)) {
      _index++;
      _consumeName();
    } else if (_wouldStartNumber(_index)) {
      _skipNumeric();
    } else if (_wouldStartUnicodeRange(_index)) {
      return _skipUnicodeRange();
    } else if (_wouldStartIdentifier(_index)) {
      _skipIdentLike();
    } else if (CssScopeUtils._closingOf.containsKey(current)) {
      _expectedClosings.add(CssScopeUtils._closingOf[current]!);
      _index++;
    } else if (_expectedClosings.isNotEmpty && _expectedClosings.last == current) {
      _expectedClosings.removeLast();
      _index++;
    } else {
      if (current == CssScopeUtils._closeBrace && _expectedClosings.isEmpty) {
        _codeUnits[_index] = CssScopeUtils._space;
      }
      _index++;
    }
    return true;
  }

  int? _at(int index) => index < _codeUnits.length ? _codeUnits[index] : null;

  void _skipComment() {
    _index += 2;
    while (_index < _codeUnits.length) {
      if (_codeUnits[_index] == CssScopeUtils._asterisk && _at(_index + 1) == CssScopeUtils._slash) {
        _index += 2;
        return;
      }
      _index++;
    }
  }

  /// An unterminated string ends, unconsumed, at the next newline.
  void _skipString(int quote) {
    _index++;
    while (_index < _codeUnits.length) {
      final current = _codeUnits[_index];
      if (current == quote) {
        _index++;
        return;
      }
      if (current == CssScopeUtils._lineFeed) {
        return;
      }
      _index += current == CssScopeUtils._backslash ? 2 : 1;
    }
  }

  void _skipNumeric() {
    if (_codeUnits[_index] == CssScopeUtils._plus || _codeUnits[_index] == CssScopeUtils._hyphen) {
      _index++;
    }
    _skipDigits();
    if (_at(_index) == CssScopeUtils._fullStop && _isDigit(_at(_index + 1))) {
      _index++;
      _skipDigits();
    }
    if (_isExponentStart()) {
      _index += _isDigit(_at(_index + 1)) ? 1 : 2;
      _skipDigits();
    }
    if (_wouldStartIdentifier(_index)) {
      _consumeName();
    } else if (_at(_index) == CssScopeUtils._percent) {
      _index++;
    }
  }

  bool _isExponentStart() {
    final current = _at(_index);
    if (current != CssScopeUtils._lowerE && current != CssScopeUtils._upperE) {
      return false;
    }
    final next = _at(_index + 1);
    return _isDigit(next)
        || ((next == CssScopeUtils._plus || next == CssScopeUtils._hyphen) && _isDigit(_at(_index + 2)));
  }

  void _skipDigits() {
    while (_isDigit(_at(_index))) {
      _index++;
    }
  }

  /// Some browsers (Chromium) tokenize `U+...` as a unicode-range token,
  /// others (Firefox) as an identifier followed by other tokens. Both agree
  /// on where it ends unless a name code point immediately follows, in which
  /// case the CSS is rejected as ambiguous.
  bool _skipUnicodeRange() {
    _index += 2;
    _skipUnicodeRangeBound(allowQuestionMarks: true);
    if (_at(_index) == CssScopeUtils._hyphen && _isHexDigit(_at(_index + 1))) {
      _index++;
      _skipUnicodeRangeBound(allowQuestionMarks: false);
    }
    return !_isNameCodeUnit(_at(_index)) && _at(_index) != CssScopeUtils._backslash;
  }

  void _skipUnicodeRangeBound({required bool allowQuestionMarks}) {
    int length = 0;
    while (length < CssScopeUtils._maxHexDigitsInUnicodeRange && _isHexDigit(_at(_index))) {
      _index++;
      length++;
    }
    while (allowQuestionMarks
        && length < CssScopeUtils._maxHexDigitsInUnicodeRange
        && _at(_index) == CssScopeUtils._questionMark) {
      _index++;
      length++;
    }
  }

  /// An identifier spelling `url` followed by `(` and an unquoted argument
  /// forms a single url token: braces, quotes and comments inside it are
  /// not interpreted.
  void _skipIdentLike() {
    final name = _consumeName();
    if (_at(_index) != CssScopeUtils._openParenthesis || name.toLowerCase() != 'url') {
      return;
    }

    int argumentStart = _index + 1;
    while (_isWhitespace(_at(argumentStart))) {
      argumentStart++;
    }
    final firstArgumentCodeUnit = _at(argumentStart);
    if (firstArgumentCodeUnit == CssScopeUtils._doubleQuote
        || firstArgumentCodeUnit == CssScopeUtils._singleQuote) {
      return;
    }

    _index = argumentStart;
    _skipUrlArgument();
  }

  /// Valid or not, an unquoted url token always ends at the first unescaped
  /// `)` or at the end of the stylesheet.
  void _skipUrlArgument() {
    while (_index < _codeUnits.length) {
      if (_codeUnits[_index] == CssScopeUtils._closeParenthesis) {
        _index++;
        return;
      }
      _index += _isValidEscape(_index) ? 2 : 1;
    }
  }

  String _consumeName() {
    final name = StringBuffer();
    while (_index < _codeUnits.length) {
      final current = _codeUnits[_index];
      if (_isValidEscape(_index)) {
        _index++;
        _consumeEscape(name);
      } else if (_isNameCodeUnit(current)) {
        name.writeCharCode(current);
        _index++;
      } else {
        break;
      }
    }
    return name.toString();
  }

  void _consumeEscape(StringBuffer output) {
    final hexStart = _index;
    while (_index - hexStart < CssScopeUtils._maxHexDigitsInEscape && _isHexDigit(_at(_index))) {
      _index++;
    }

    if (_index == hexStart) {
      output.writeCharCode(_codeUnits[_index]);
      _index++;
      return;
    }

    final codePoint = int.parse(String.fromCharCodes(_codeUnits.sublist(hexStart, _index)), radix: 16);
    output.writeCharCode(_isValidCodePoint(codePoint) ? codePoint : CssScopeUtils._replacementCharacter);
    if (_isWhitespace(_at(_index))) {
      _index++;
    }
  }

  bool _isHashStart(int index) => _isNameCodeUnit(_at(index)) || _isValidEscape(index);

  bool _wouldStartIdentifier(int index) {
    final current = _at(index);
    if (current == CssScopeUtils._hyphen) {
      final next = _at(index + 1);
      return _isNameStartCodeUnit(next) || next == CssScopeUtils._hyphen || _isValidEscape(index + 1);
    }
    return _isNameStartCodeUnit(current) || _isValidEscape(index);
  }

  bool _wouldStartNumber(int index) {
    final current = _at(index);
    if (current == CssScopeUtils._plus || current == CssScopeUtils._hyphen) {
      final next = _at(index + 1);
      return _isDigit(next) || (next == CssScopeUtils._fullStop && _isDigit(_at(index + 2)));
    }
    if (current == CssScopeUtils._fullStop) {
      return _isDigit(_at(index + 1));
    }
    return _isDigit(current);
  }

  bool _wouldStartUnicodeRange(int index) {
    final current = _at(index);
    final afterPlus = _at(index + 2);
    return (current == CssScopeUtils._lowerU || current == CssScopeUtils._upperU)
        && _at(index + 1) == CssScopeUtils._plus
        && (_isHexDigit(afterPlus) || afterPlus == CssScopeUtils._questionMark);
  }

  bool _isValidEscape(int index) {
    final next = _at(index + 1);
    return _at(index) == CssScopeUtils._backslash && next != null && next != CssScopeUtils._lineFeed;
  }

  static bool _isValidCodePoint(int codePoint) =>
      codePoint != 0 && codePoint <= 0x10FFFF && (codePoint < 0xD800 || codePoint > 0xDFFF);

  static bool _isNameStartCodeUnit(int? codeUnit) =>
      codeUnit != null
          && ((codeUnit >= 0x61 && codeUnit <= 0x7A)
              || (codeUnit >= 0x41 && codeUnit <= 0x5A)
              || codeUnit == CssScopeUtils._underscore
              || codeUnit >= 0x80);

  static bool _isNameCodeUnit(int? codeUnit) =>
      _isNameStartCodeUnit(codeUnit) || _isDigit(codeUnit) || codeUnit == CssScopeUtils._hyphen;

  static bool _isDigit(int? codeUnit) => codeUnit != null && codeUnit >= 0x30 && codeUnit <= 0x39;

  static bool _isHexDigit(int? codeUnit) =>
      codeUnit != null
          && (_isDigit(codeUnit)
              || (codeUnit >= 0x41 && codeUnit <= 0x46)
              || (codeUnit >= 0x61 && codeUnit <= 0x66));

  static bool _isWhitespace(int? codeUnit) =>
      codeUnit == CssScopeUtils._lineFeed || codeUnit == CssScopeUtils._space || codeUnit == CssScopeUtils._tab;
}
