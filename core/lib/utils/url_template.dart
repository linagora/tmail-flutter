/// Resolves named variables in a URL template.
///
/// Both raw (`{name}`) and URL-encoded (`%7Bname%7D`) placeholders are
/// supported. A template cannot be resolved when it uses a variable whose
/// value is unavailable.
class UrlTemplate {
  final String _value;
  final _ParsedUrlTemplate _parsedTemplate;

  UrlTemplate(String value)
      : _value = value,
        _parsedTemplate = _UrlTemplateScanner(value).scan();

  UrlTemplate.withSelectedEncodedPlaceholders(
    String value, {
    required Set<String> encodedPlaceholderNames,
  }) : _value = value,
       _parsedTemplate = _UrlTemplateScanner(
         value,
         encodedPlaceholderNames: encodedPlaceholderNames,
       ).scan();

  String? resolve({
    required Map<String, String?> variables,
    Set<String> caseInsensitiveVariables = const {},
  }) {
    if (!_parsedTemplate.isWellFormed) return null;
    if (_parsedTemplate.placeholderNames.isEmpty) return _value;

    final output = StringBuffer();
    for (final token in _parsedTemplate.tokens) {
      final resolvedToken = _resolveToken(
        token,
        variables,
        caseInsensitiveVariables,
      );
      if (resolvedToken == null) return null;
      output.write(resolvedToken);
    }
    return output.toString();
  }

  bool usesPlaceholder(
    String name, {
    bool caseSensitive = true,
  }) {
    if (!_parsedTemplate.isWellFormed) return false;

    for (final placeholderName in _parsedTemplate.placeholderNames) {
      final matches = caseSensitive
          ? placeholderName == name
          : _equalsAsciiCaseInsensitive(placeholderName, name);
      if (matches) return true;
    }
    return false;
  }

  bool hasOnlySupportedPlaceholders({
    required Set<String> names,
    Set<String> caseInsensitiveNames = const {},
  }) {
    if (!_parsedTemplate.isWellFormed) return false;

    return _parsedTemplate.placeholderNames.every((placeholderName) =>
        names.contains(placeholderName) ||
        caseInsensitiveNames.any((name) =>
            _equalsAsciiCaseInsensitive(placeholderName, name)));
  }
}

String? _resolveToken(
  _UrlTemplateToken token,
  Map<String, String?> variables,
  Set<String> caseInsensitiveVariables,
) => switch (token) {
  _LiteralToken(:final value) => value,
  _PlaceholderToken(:final source, :final name) => _resolvePlaceholder(
      source,
      name,
      variables,
      caseInsensitiveVariables,
    ),
};

String? _resolvePlaceholder(
  String source,
  String name,
  Map<String, String?> variables,
  Set<String> caseInsensitiveVariables,
) {
  final variableName = _findVariableName(
    name,
    variables,
    caseInsensitiveVariables,
  );
  if (variableName == null) return source;
  return variables[variableName];
}

String? _findVariableName(
  String placeholderName,
  Map<String, String?> variables,
  Set<String> caseInsensitiveVariables,
) {
  if (variables.containsKey(placeholderName) &&
      !caseInsensitiveVariables.contains(placeholderName)) {
    return placeholderName;
  }

  for (final variable in variables.entries) {
    if (caseInsensitiveVariables.contains(variable.key) &&
        _equalsAsciiCaseInsensitive(placeholderName, variable.key)) {
      return variable.key;
    }
  }
  return null;
}

final class _ParsedUrlTemplate {
  final List<_UrlTemplateToken> tokens;
  final List<String> placeholderNames;
  final bool isWellFormed;

  const _ParsedUrlTemplate({
    required this.tokens,
    required this.placeholderNames,
    required this.isWellFormed,
  });

  const _ParsedUrlTemplate.malformed()
      : tokens = const [],
        placeholderNames = const [],
        isWellFormed = false;
}

sealed class _UrlTemplateToken {
  const _UrlTemplateToken();
}

final class _LiteralToken extends _UrlTemplateToken {
  final String value;

  const _LiteralToken(this.value);
}

final class _PlaceholderToken extends _UrlTemplateToken {
  final String source;
  final String name;

  const _PlaceholderToken({
    required this.source,
    required this.name,
  });
}

final class _UrlTemplateScanner {
  final String source;
  final Set<String>? encodedPlaceholderNames;
  final _tokens = <_UrlTemplateToken>[];
  final _placeholderNames = <String>[];
  var _placeholderType = _PlaceholderType.none;
  var _placeholderStart = 0;
  var _nameStart = 0;
  var _literalStart = 0;
  var _index = 0;
  var _isMalformed = false;

  _UrlTemplateScanner(
    this.source, {
    this.encodedPlaceholderNames,
  });

  _ParsedUrlTemplate scan() {
    while (_index < source.length && !_isMalformed) {
      _scanCurrentCodeUnit();
    }
    if (_isMalformed || _placeholderType != _PlaceholderType.none) {
      return const _ParsedUrlTemplate.malformed();
    }
    _addLiteralToken(_literalStart, source.length);
    return _ParsedUrlTemplate(
      tokens: List.unmodifiable(_tokens),
      placeholderNames: List.unmodifiable(_placeholderNames),
      isWellFormed: true,
    );
  }

  void _scanCurrentCodeUnit() {
    if (_scanEncodedOpeningMarker()) return;
    if (_scanEncodedClosingMarker()) return;
    _scanRawMarker();
  }

  bool _scanEncodedOpeningMarker() {
    if (!_isEncodedMarkerAt(source, _index, 0x62)) return false;
    _openPlaceholder(_PlaceholderType.encoded, 3);
    return true;
  }

  bool _scanEncodedClosingMarker() {
    if (!_isEncodedMarkerAt(source, _index, 0x64)) return false;
    _closePlaceholder(_PlaceholderType.encoded, 3);
    return true;
  }

  void _scanRawMarker() {
    final codeUnit = source.codeUnitAt(_index);
    if (codeUnit == 0x7B) {
      _openPlaceholder(_PlaceholderType.raw, 1);
      return;
    }
    if (codeUnit == 0x7D) {
      _closePlaceholder(_PlaceholderType.raw, 1);
      return;
    }
    _index++;
  }

  void _openPlaceholder(_PlaceholderType type, int markerLength) {
    if (_placeholderType != _PlaceholderType.none) {
      _isMalformed = true;
      return;
    }
    _addLiteralToken(_literalStart, _index);
    _placeholderType = type;
    _placeholderStart = _index;
    _nameStart = _index + markerLength;
    _index = _nameStart;
  }

  void _closePlaceholder(_PlaceholderType type, int markerLength) {
    if (_placeholderType != type) {
      _isMalformed = true;
      return;
    }
    if (_index == _nameStart) {
      _isMalformed = true;
      return;
    }
    final placeholderEnd = _index + markerLength;
    final name = source.substring(_nameStart, _index);
    final placeholderSource = source.substring(
      _placeholderStart,
      placeholderEnd,
    );
    if (_isSupportedPlaceholder(type, name)) {
      _tokens.add(_PlaceholderToken(
        source: placeholderSource,
        name: name,
      ));
      _placeholderNames.add(name);
    } else {
      _tokens.add(_LiteralToken(placeholderSource));
    }
    _placeholderType = _PlaceholderType.none;
    _index = placeholderEnd;
    _literalStart = placeholderEnd;
  }

  void _addLiteralToken(int start, int end) {
    if (start >= end) return;
    _tokens.add(_LiteralToken(source.substring(start, end)));
  }

  bool _isSupportedPlaceholder(_PlaceholderType type, String name) =>
      type == _PlaceholderType.raw ||
      encodedPlaceholderNames == null ||
      encodedPlaceholderNames!.any((placeholderName) =>
          _equalsAsciiCaseInsensitive(name, placeholderName));
}

enum _PlaceholderType { none, raw, encoded }

bool _isEncodedMarkerAt(String input, int index, int finalCodeUnit) =>
    index + 2 < input.length &&
    input.codeUnitAt(index) == 0x25 &&
    input.codeUnitAt(index + 1) == 0x37 &&
    _toLowerAscii(input.codeUnitAt(index + 2)) == finalCodeUnit;

int _toLowerAscii(int codeUnit) =>
    codeUnit >= 0x41 && codeUnit <= 0x5A ? codeUnit + 0x20 : codeUnit;

bool _equalsAsciiCaseInsensitive(String first, String second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (_toLowerAscii(first.codeUnitAt(index)) !=
        _toLowerAscii(second.codeUnitAt(index))) {
      return false;
    }
  }
  return true;
}
