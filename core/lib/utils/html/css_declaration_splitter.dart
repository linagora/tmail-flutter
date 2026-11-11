class CssDeclarationSplitter {
  const CssDeclarationSplitter._();

  /// Splits [style] at top-level `;`, ignoring semicolons inside quotes,
  /// comments, or parentheses, and honoring CSS `\` escapes. Each declaration
  /// keeps its original text (including any trailing `;`). Returns `null` for
  /// malformed CSS (unterminated quote/comment, unbalanced parenthesis, or a
  /// trailing backslash). Single linear scan — no backtracking, so ReDoS-immune
  /// (ADR 0069-redos-vulnerability-mitigation).
  static List<String>? splitTopLevel(String style) => _Scan(style).run();
}

class _Scan {
  _Scan(this._style);

  final String _style;
  final _declarations = <String>[];
  var _index = 0;
  var _start = 0;
  var _quote = ''; // active quote char, or '' outside a string
  var _inComment = false;
  var _parenDepth = 0;

  bool get _hasOpenToken => _inComment || _quote.isNotEmpty;

  String get _char => _style[_index];

  String get _next => _index + 1 < _style.length ? _style[_index + 1] : '';

  List<String>? run() {
    for (_index = 0; _index < _style.length; _index++) {
      if (!_step()) return null;
    }
    if (_hasOpenToken || _parenDepth != 0) return null; // unterminated
    if (_start < _style.length) _declarations.add(_style.substring(_start));
    return _declarations;
  }

  /// Returns `false` when the CSS is malformed.
  bool _step() {
    if (_inComment) {
      _stepComment();
      return true;
    }
    if (_quote.isNotEmpty) {
      _stepQuoted();
      return true;
    }
    return _stepCode();
  }

  void _stepComment() {
    if (_char == '*' && _next == '/') {
      _inComment = false;
      _index++;
    }
  }

  void _stepQuoted() {
    if (_char == '\\') {
      _index++; // skip the escaped character
    } else if (_char == _quote) {
      _quote = '';
    }
  }

  bool _stepCode() => switch (_char) {
    '\\' => _skipEscape(),
    '/' => _openComment(),
    '"' || "'" => _openQuote(),
    '(' => _openParen(),
    ')' => _closeParen(),
    ';' => _closeDeclaration(),
    _ => true,
  };

  bool _skipEscape() {
    if (_next.isEmpty) return false; // trailing backslash → fail-open
    _index++; // escaped char is literal data (e.g. `\;`), never a boundary
    return true;
  }

  bool _openQuote() {
    _quote = _char;
    return true;
  }

  bool _openParen() {
    _parenDepth++;
    return true;
  }

  bool _closeParen() {
    if (_parenDepth == 0) return false; // unbalanced
    _parenDepth--;
    return true;
  }

  // Inside parentheses `/*` is data, not a comment — an unquoted
  // `url(https://x/a/*/b.png)` must not poison the whole attribute
  // (fail-open would keep a degenerate line-height → TF-3964 returns).
  bool _openComment() {
    if (_next == '*' && _parenDepth == 0) {
      _inComment = true;
      _index++;
    }
    return true;
  }

  bool _closeDeclaration() {
    if (_parenDepth == 0) {
      _declarations.add(_style.substring(_start, _index + 1));
      _start = _index + 1;
    }
    return true;
  }
}
